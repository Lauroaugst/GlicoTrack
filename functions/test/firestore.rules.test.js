'use strict';
const {test, before, beforeEach, after} = require('node:test');
const {readFileSync} = require('node:fs');
const {resolve} = require('node:path');
const {initializeTestEnvironment, assertSucceeds, assertFails} = require('@firebase/rules-unit-testing');
const {doc, setDoc, getDoc, deleteDoc, serverTimestamp} = require('firebase/firestore');
let env;
const id = '11111111-1111-4111-8111-111111111111';
const data = () => ({id,uid:'alice',kind:'record',revision:`0000000000000100-${id}`,baseRevision:null,updatedAt:100,deleted:false,
  payload:{glucose:120,measuredAt:100,category:'fasting',meal:'breakfast',createdAt:100,insulin:2,carbs:30,notes:''},changedAt:serverTimestamp()});
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw Error('Run with firebase emulators:exec; production access is forbidden.');
  env = await initializeTestEnvironment({projectId:'demo-glicotrack',firestore:{rules:readFileSync(resolve(__dirname,'../../firestore.rules'),'utf8')}});
});
beforeEach(async () => { await env.clearFirestore(); });
after(async () => { await env?.cleanup(); });
const db = (uid='alice') => env.authenticatedContext(uid,{email:`${uid}@example.com`}).firestore();
const ref = (database, uid='alice') => doc(database, `users/${uid}/documents/${id}`);

test('owner can write and read a valid record', async () => {
  await assertSucceeds(setDoc(ref(db()), data())); await assertSucceeds(getDoc(ref(db())));
});
test('unauthenticated requests and another account cannot read or write', async () => {
  await assertSucceeds(setDoc(ref(db()),data()));
  await assertFails(getDoc(ref(env.unauthenticatedContext().firestore())));
  await assertFails(getDoc(ref(db('bob')))); await assertFails(setDoc(ref(db('bob')),data()));
});
test('forged owner, invalid values, clinical categories and extra fields rejected', async () => {
  for (const patch of [{uid:'bob'}, {payload:{...data().payload,glucose:0}}, {payload:{...data().payload,category:'invented'}}, {secret:'extra'}]) {
    await assertFails(setDoc(ref(db()), {...data(),...patch}));
  }
});
test('requires server timestamp and prevents physical deletion and resurrection', async () => {
  await assertFails(setDoc(ref(db()),{...data(),changedAt:100}));
  await assertSucceeds(setDoc(ref(db()),{...data(),deleted:true}));
  await assertFails(setDoc(ref(db()),data())); await assertFails(deleteDoc(ref(db())));
});
test('personalized range cannot relabel hypoglycemia', async () => {
  const rangeRef = doc(db(),'users/alice/documents/settings');
  const settings = {...data(),id:'settings',kind:'settings',payload:{lower:90,upper:170}};
  await assertSucceeds(setDoc(rangeRef,settings));
  await assertFails(setDoc(rangeRef,{...settings,payload:{lower:60,upper:170}}));
});
test('profile email must match authenticated account', async () => {
  const profileRef = doc(db(),'users/alice/documents/profile');
  const profile = {...data(),id:'profile',kind:'profile',payload:{name:'Alice',email:'alice@example.com',createdAt:100,age:null,weight:null,photo:null}};
  await assertSucceeds(setDoc(profileRef, profile));
  await assertFails(setDoc(profileRef,{...profile,payload:{...profile.payload,email:'bob@example.com'}}));
});
test('deletion lock blocks stale offline uploads and reads', async () => {
  await assertSucceeds(setDoc(ref(db()),data()));
  await env.withSecurityRulesDisabled(async context => { await setDoc(doc(context.firestore(),'deletionRequests/alice'),{state:'deleting'}); });
  await assertFails(setDoc(ref(db()),data())); await assertFails(getDoc(ref(db())));
  await assertFails(setDoc(doc(db(),'deletionRequests/alice'),{state:'completed'}));
});
test('conflict archive is private, immutable and idempotent', async () => {
  const conflict = data(); delete conflict.changedAt;
  const conflictRef = doc(db(),`users/alice/conflicts/${id}_${conflict.revision}`);
  await assertSucceeds(setDoc(conflictRef,conflict)); await assertSucceeds(setDoc(conflictRef,conflict));
  await assertFails(setDoc(conflictRef,{...conflict,payload:{...conflict.payload,glucose:200}}));
  await assertFails(getDoc(doc(db('bob'),conflictRef.path)));
});
