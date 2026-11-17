import assert from 'node:assert/strict';
import {createRecordsAdapter} from './supabase-adapter.mjs';
// These tests use a mock client. They do not establish live RLS or email delivery.
const calls=[];
const client={
 auth:{getUser:async()=>({data:{user:{id:'A',email_confirmed_at:'2026-11-18T00:00:00Z'}},error:null}),signInWithOtp:async x=>{calls.push(x);return {data:{},error:null}},verifyOtp:async x=>{calls.push(x);return {data:{},error:null}},signOut:async()=>({data:null,error:null})},
 from:table=>({insert:async row=>{calls.push({table,row});return {data:null,error:{code:'23505',message:'duplicate'}}}}),
 rpc:async(name,args)=>{calls.push({name,args});return {data:{version:2},error:null}}
};
let n=0;const ok=msg=>console.log('PASS',++n,msg);
assert.throws(()=>createRecordsAdapter({}),TypeError);ok('Reject absent client');
const api=createRecordsAdapter(client);
await assert.rejects(()=>api.requestEmailCode('not-an-email'),TypeError);ok('Reject malformed email');
await api.requestEmailCode(' user@example.com ');assert.equal(calls.at(-1).email,'user@example.com');ok('Trim validated email');
await assert.rejects(()=>api.verifyEmailCode('u@example.com','bad'),TypeError);ok('Reject invalid OTP');
await assert.rejects(()=>api.setProgress('r',101,1),TypeError);ok('Validate progress range');
await api.setProgress('r',50,1);assert.equal(calls.at(-1).args.p_expected_version,1);ok('Send optimistic concurrency version');
assert.equal(await api.bookmark('r',true),null);ok('Treat duplicate bookmark as idempotent success');
client.rpc=async()=>({data:null,error:{code:'40001',message:'Reload'}});
await assert.rejects(()=>api.setProgress('r',75,1),e=>e.code==='40001');ok('Surface write conflicts');
client.auth.getUser=async()=>({data:{user:{id:'A'}},error:null});
await assert.rejects(()=>api.bookmark('r',true),/verified/);ok('Reject unconfirmed email account');
console.log(JSON.stringify({passed:n,scope:'Mock client only; no live Supabase/RLS or email request'}));
