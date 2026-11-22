'use strict';
const {test, before, after} = require('node:test');
const assert = require('node:assert/strict');
const {initializeApp, deleteApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {getAuth} = require('firebase-admin/auth');
let app, db, auth;
const project = 'demo-glicotrack';
const functionsOrigin = process.env.FUNCTIONS_EMULATOR_ORIGIN || 'http://127.0.0.1:5001';
before(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) throw Error('Emulators required; production access forbidden.');
  app = initializeApp({projectId:project},'integration'); db = getFirestore(app); auth = getAuth(app);
});
after(async () => { if (app) await deleteApp(app); });
async function signup(email) {
  const response = await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key`, {
    method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email,password:'Test-password-2026!',returnSecureToken:true}),
  });
  assert.equal(response.status,200); return response.json();
}
test('callable rejects unauthenticated deletion', async () => {
  const response = await fetch(`${functionsOrigin}/${project}/us-central1/deleteMyAccount`,{
    method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({data:{uid:'another-account'}}),
  });
  assert.equal(response.status,401);
});
test('anonymous session can delete its own data without password and preserves another session', async () => {
  const response = await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key`, {
    method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({returnSecureToken:true}),
  });
  assert.equal(response.status,200);
  const guest = await response.json();
  const other = await signup(`other-${Date.now()}@example.com`);
  await db.doc(`users/${guest.localId}/documents/test`).set({dummy:true});
  await db.doc(`users/${other.localId}/documents/test`).set({dummy:true});
  const deletion = await fetch(`${functionsOrigin}/${project}/us-central1/deleteMyAccount`, {
    method:'POST',headers:{'content-type':'application/json',authorization:`Bearer ${guest.idToken}`},body:JSON.stringify({data:{uid:other.localId}}),
  });
  assert.equal(deletion.status,200,await deletion.text());
  await assert.rejects(auth.getUser(guest.localId),{code:'auth/user-not-found'});
  assert.equal((await db.collection(`users/${guest.localId}/documents`).get()).size,0);
  assert.equal((await db.doc(`users/${other.localId}/documents/test`).get()).exists,true);
  assert.equal((await auth.getUser(other.localId)).uid,other.localId);
  assert.equal((await db.doc(`deletionRequests/${guest.localId}`).get()).data().state,'completed');
});
test('authenticated callable deletes own nested data and auth, preserves another account and blocks stale data', async () => {
  const suffix = Date.now();
  const alice = await signup(`alice-${suffix}@example.com`);
  const bob = await signup(`bob-${suffix}@example.com`);
  await db.doc(`users/${alice.localId}/documents/test`).set({dummy:true});
  await db.doc(`users/${alice.localId}/conflicts/test`).set({dummy:true});
  await db.doc(`users/${bob.localId}/documents/test`).set({dummy:true});
  const response = await fetch(`${functionsOrigin}/${project}/us-central1/deleteMyAccount`, {
    method:'POST',headers:{'content-type':'application/json',authorization:`Bearer ${alice.idToken}`},body:JSON.stringify({data:{uid:bob.localId}}),
  });
  assert.equal(response.status,200,await response.text());
  assert.equal((await db.collection(`users/${alice.localId}/documents`).get()).size,0);
  assert.equal((await db.collection(`users/${alice.localId}/conflicts`).get()).size,0);
  assert.equal((await db.doc(`users/${bob.localId}/documents/test`).get()).exists,true);
  await assert.rejects(auth.getUser(alice.localId),{code:'auth/user-not-found'});
  assert.equal((await auth.getUser(bob.localId)).uid,bob.localId);
  assert.equal((await db.doc(`deletionRequests/${alice.localId}`).get()).data().state,'completed');
});
