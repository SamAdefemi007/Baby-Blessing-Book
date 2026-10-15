# Baby Blessing Book — GitHub Pages + Supabase

## Deploy
1. Create a Supabase Free project. Open **SQL Editor** and run `supabase.sql`.
2. In **Project Settings → API**, copy the **Project URL** and the **publishable key** (or legacy `anon` key). Put both into `config.js`. NEVER use a `service_role`/secret key in client code.
3. In **Authentication → URL Configuration**, set **Site URL** to `https://samadefemi007.github.io/Baby-Blessing-Book/` and add **Redirect URL** `https://samadefemi007.github.io/Baby-Blessing-Book/admin.html` (exact path/case).
4. Upload `index.html`, `admin.html`, `config.js` to the root of your existing GitHub Pages repository. `supabase.sql` and this README can remain in the repository; they contain no secrets.
5. Open `/admin.html` and request an email magic link. Click it and sign in once. In Supabase **Authentication → Users**, copy your account's UUID. In SQL Editor, run:
   `insert into public.blessing_admins(user_id) values ('YOUR_AUTH_USER_UUID') on conflict do nothing;`
   Repeat for the second parent. Refresh `/admin.html`.
6. Test public submission with a dummy blessing and confirm it appears in the dashboard. Test from an incognito browser that no blessings are readable through Supabase REST (RLS). Test CSV, JSON and Print → Save as PDF.

## URLs
- Public: https://samadefemi007.github.io/Baby-Blessing-Book/
- Private dashboard: https://samadefemi007.github.io/Baby-Blessing-Book/admin.html

## Important security and reliability notes
- Anyone who knows the admin URL can *request* a sign-in link, but only user IDs in `blessing_admins` can read messages.
- Disable public account sign-ups in Supabase Auth settings **after** both parents have created accounts if desired; make sure email OTP still works for existing users.
- Anonymous insert-only policies prevent reading others' wishes, but do not prevent spam. For a public link, consider adding Turnstile + a server-side Supabase Edge Function before wider sharing. Client-side honeypots are only a light deterrent.
- Avoid storing addresses, phone numbers, or sensitive personal information in wishes. Treat exports as private.
- The dashboard loads the latest 1,000 entries. For a small ceremony that is more than enough; implement pagination if needed.
- The PDF export is via the browser print dialog (Print → Save as PDF), and uses print-friendly card styling. CSV and JSON are direct downloads.
- Free Supabase projects can pause due to inactivity; export and back up messages immediately after the event.
- Do not reveal the baby's name in the public invitation or form. You may personalize the private keepsake later.
