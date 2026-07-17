# 2026 FIFA World Cup Pool

A Rails 7 + Postgres pool app for the 2026 FIFA World Cup. Open registration, single shared pool, admin role for entering results.

## Tournament & scoring

- 48 teams in 12 groups of 4 (Dec 2025 draw seeded)
- 72 group games + 31 knockout matches (R32 → R16 → QF → SF → Final)
- Group pick = W/L/T per game. **1 point** per correct pick.
- Knockout = full bracket filled in up front. **R32 = 2, R16 = 3, QF = 4, SF = 5, Final = 6**.
- Group picks lock at first group kickoff. Bracket picks lock at first R32 kickoff. No late picks.
- Standings: total points, descending. Ties stay tied.

## Stack

- Rails 7.2, Ruby 3.3
- Postgres
- Devise (email + password)
- Hotwire / Turbo + Tailwind CSS
- Server-rendered

## Local development

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev   # foreman: rails server + tailwind watch
```

To create an admin user locally:

```ruby
User.create!(email: "you@example.com", password: "...", display_name: "You", admin: true)
```

## Deploy to Heroku

```bash
heroku create
heroku addons:create heroku-postgresql:essential-0
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key) \
                   ADMIN_EMAIL=you@example.com \
                   ADMIN_PASSWORD=changeme \
                   ADMIN_DISPLAY_NAME=Commissioner
git push heroku main
heroku run rails db:seed
```

The included `app.json` and `Procfile` configure the release phase to run `db:prepare` and the postdeploy hook to seed teams/groups/fixtures.

### Email (password reset, etc.)

Devise sends password-reset emails over SMTP. Production has no built-in mail
server, so you need to attach an email provider. The easiest option on Heroku is
the **SendGrid** add-on, which provisions SMTP credentials automatically:

```bash
heroku addons:create sendgrid:starter
heroku config:set APP_HOST=your-app.herokuapp.com \
                  MAILER_SENDER=no-reply@yourdomain.com
```

`APP_HOST` is required so the reset links in the email point at your app. Once
the add-on is attached, no secrets need to be set by hand — the app reads the
`SENDGRID_USERNAME` / `SENDGRID_PASSWORD` config vars the add-on creates.

To use a different provider (Mailgun, Postmark, Amazon SES, …) instead, skip the
add-on and set the generic SMTP vars:

```bash
heroku config:set SMTP_ADDRESS=smtp.yourprovider.com \
                  SMTP_PORT=587 \
                  SMTP_USERNAME=... \
                  SMTP_PASSWORD=... \
                  APP_HOST=your-app.herokuapp.com \
                  MAILER_SENDER=no-reply@yourdomain.com
```

### Media storage for `/feed` (required on Heroku)

The `/feed` photo & video gallery uses Active Storage. Heroku's file system is
**ephemeral** — files written to local disk are wiped on every deploy and on the
daily dyno restart — so production defaults to Amazon S3. Provide a bucket with
either of these approaches:

**Option A — your own S3 bucket:**

```bash
heroku config:set AWS_ACCESS_KEY_ID=... \
                   AWS_SECRET_ACCESS_KEY=... \
                   AWS_REGION=us-east-1 \
                   AWS_BUCKET=your-bucket-name
```

**Option B — Bucketeer add-on** (sets `BUCKETEER_*` vars automatically):

```bash
heroku addons:create bucketeer:hobbyist
```

Uploads use Active Storage **direct uploads** (browser → S3), which keeps large
videos from hitting Heroku's 30-second request timeout. For this the bucket
needs a CORS policy. Set `APP_HOST` to your app's hostname, then run the
included task (works for both your own bucket and Bucketeer):

```bash
heroku config:set APP_HOST=your-app.herokuapp.com
heroku run rails storage:configure_cors
```

Verify the whole storage path end-to-end with a round-trip smoke test:

```bash
heroku run rails storage:check
```

If `configure_cors` reports **access denied** (some add-on credentials can't
change the bucket policy), fall back to proxied uploads — they route through
the dyno and need no CORS (fine for photos and short clips):

```bash
heroku config:set ACTIVE_STORAGE_DIRECT_UPLOADS=false
```

To run against local disk instead (e.g. a non-Heroku host with a persistent
volume), set `ACTIVE_STORAGE_SERVICE=local`.

## Admin operations

After signing in as admin, visit `/admin`:
- **Group matches**: enter final scores for each of the 72 fixtures. Result (`home`/`draw`/`away`) is derived from scores and group picks are rescored automatically.
- **Knockout matches**: enter scores; winner advances and feeds the next round's bracket slot. Bracket picks rescore on save.
- **Teams**: rename play-off placeholders and reassign groups (useful when the Inter-Confed/UEFA play-off winners are decided).
- **Recompute scores**: re-runs the full scoring + slot-resolution pipeline.
