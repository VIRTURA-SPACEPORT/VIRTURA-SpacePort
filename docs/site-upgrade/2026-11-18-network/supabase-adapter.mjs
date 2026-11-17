/**
 * Inject an official supabase-js v2 client from a trusted app entry point.
 * This module is NOT connected to preview.html and contains no keys.
 * Supabase URL/publishable key belong in deployment configuration.
 * Never pass a secret/service_role key to a browser client.
 */
export function createRecordsAdapter(client) {
  if (!client?.auth || typeof client.from !== 'function' || typeof client.rpc !== 'function') {
    throw new TypeError('An initialized Supabase client is required');
  }
  const unwrap = (result) => {
    if (result.error) throw Object.assign(new Error(result.error.message), {code: result.error.code});
    return result.data;
  };
  const validId = (id) => {
    if (typeof id !== 'string' || !id.length || id.length > 128) throw new TypeError('Invalid resource ID');
    return id;
  };
  const user = async () => {
    const data = unwrap(await client.auth.getUser());
    if (!data?.user || data.user.is_anonymous || !data.user.email_confirmed_at) throw new Error('Sign in with a verified account first');
    return data.user;
  };
  return {
    async requestEmailCode(email) {
      if (typeof email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) throw new TypeError('Invalid email');
      // Configure the Supabase Email template to include {{ .Token }} for OTP.
      return unwrap(await client.auth.signInWithOtp({email: email.trim(), options: {shouldCreateUser: true}}));
    },
    async verifyEmailCode(email, token) {
      if (typeof email !== 'string' || typeof token !== 'string' || !/^\d{6,10}$/.test(token)) throw new TypeError('Invalid email code');
      return unwrap(await client.auth.verifyOtp({email: email.trim(), token, type: 'email'}));
    },
    async load() {
      const u = await user();
      const [resources, bookmarks, progress] = await Promise.all([
        client.from('vcn_resources').select('id,kind,title,url').eq('published', true),
        client.from('vcn_bookmarks').select('resource_id,created_at').eq('user_id', u.id),
        client.from('vcn_progress').select('resource_id,percent,version,updated_at').eq('user_id', u.id)
      ]);
      return {userId: u.id, resources: unwrap(resources), bookmarks: unwrap(bookmarks), progress: unwrap(progress)};
    },
    async bookmark(id, enabled) {
      validId(id); const u = await user();
      if (typeof enabled !== 'boolean') throw new TypeError('Expected boolean');
      if (!enabled) return unwrap(await client.from('vcn_bookmarks').delete().eq('user_id', u.id).eq('resource_id', id));
      const result = await client.from('vcn_bookmarks').insert({user_id: u.id, resource_id: id});
      // Duplicate bookmark is an idempotent success, not a new record.
      if (result.error?.code === '23505') return null;
      return unwrap(result);
    },
    async setProgress(id, percent, expectedVersion) {
      validId(id); await user();
      if (!Number.isInteger(percent) || percent < 0 || percent > 100 || !Number.isInteger(expectedVersion) || expectedVersion < 0) throw new TypeError('Invalid progress/version');
      // 40001 means another device saved first; show a conflict, reload, and ask.
      return unwrap(await client.rpc('vcn_set_progress', {p_resource_id: id, p_percent: percent, p_expected_version: expectedVersion}));
    },
    async exportOwnRecords() {
      const records = await this.load();
      return {schemaVersion: 1, exportedAt: new Date().toISOString(), ...records};
    },
    async signOut() { return unwrap(await client.auth.signOut({scope: 'global'})); }
  };
}
