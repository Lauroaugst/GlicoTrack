'use strict';

// The permanent lock is outside /users: recursive deletion never removes it.
// Locks contain no medical records; clients cannot create/remove or read them.
async function deleteUserData(uid, {db, auth}) {
  const lock = db.collection('deletionRequests').doc(uid);
  await lock.set({state: 'deleting'}, {merge: true});
  await db.recursiveDelete(db.collection('users').doc(uid));
  try {
    await auth.deleteUser(uid);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
  }
  await lock.set({state: 'completed'});
  return {deleted: true};
}

module.exports = {deleteUserData};
