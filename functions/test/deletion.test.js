'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const {deleteUserData} = require('../deletion');

function fixture({failDelete = false, missingUser = false} = {}) {
  const events = [];
  return {
    events,
    db: {
      collection: name => ({doc: uid => ({path: `${name}/${uid}`, set: async data => events.push([name, uid, data.state])})}),
      recursiveDelete: async ref => { events.push(['purge', ref.path]); if (failDelete) throw Error('offline'); },
    },
    auth: {deleteUser: async uid => { events.push(['auth',uid]); if (missingUser) throw Object.assign(Error(), {code: 'auth/user-not-found'}); }},
  };
}
test('locks before recursive deletion and removes only authenticated user path', async () => {
  const f = fixture(); await deleteUserData('alice', f);
  assert.deepEqual(f.events, [['deletionRequests','alice','deleting'], ['purge','users/alice'], ['auth','alice'], ['deletionRequests','alice','completed']]);
});
test('failed purge retains lock and does not delete auth prematurely', async () => {
  const f = fixture({failDelete: true});
  await assert.rejects(deleteUserData('alice',f));
  assert.equal(f.events.length, 2);
});
test('retry tolerates an already deleted Firebase account', async () => {
  const f = fixture({missingUser: true});
  assert.deepEqual(await deleteUserData('alice',f), {deleted:true});
  assert.equal(f.events.at(-1)[2], 'completed');
});
