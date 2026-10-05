# Kapok – Client Action Guide: Getting on the App Store & Google Play

**Date:** 2026-05-26
**Audience:** A Fair Resolution, LLC (the app owner) — *not* the engineering team
**Companion document:** [`15_store_readiness_evaluation.md`](15_store_readiness_evaluation.md) covers the technical / engineering work. This document covers everything that **only you, the business owner, can do.**

---

## How to read this document

Publishing Kapok is split between two parties:

| Who | Does what | Where it's documented |
| --- | --- | --- |
| **You** (A Fair Resolution, LLC) | Open and own the developer accounts, pay the fees, accept the legal contracts, supply legal/marketing content, make the business decisions, grant the engineer access. | **This document (§16)** |
| **Engineer / dev team** | Configure signing, bundle IDs, build the binaries, upload them, fill in the technical forms. | [§15](15_store_readiness_evaluation.md) |

The engineering tasks in §15 **cannot start in earnest until the accounts in this document exist**, because the developer accounts, the bundle identifiers, and the signing identities all belong to *your* legal entity, not the engineer's. The engineer can do almost everything *inside* those accounts once you create them and grant access — but only you can create them, because they require your company's legal identity, payment method, and signature on Apple's and Google's contracts.

> **The single most important early action:** start the **D-U-N-S number** (§1) today. Both stores require it for an organization account, and it can take days to weeks to issue. Everything else waits on it.

---

## 1. Get a D-U-N-S Number (do this first — it's the long pole)

A **D-U-N-S Number** is a free, nine-digit business identifier issued by Dun & Bradstreet. **Both Apple and Google now require it** to register a *company / organization* developer account (as opposed to a personal/individual account). You only need **one** — the same number works for both stores.

- **Cost:** Free.
- **How long:** Often a few days; can take up to ~30 days if Dun & Bradstreet has to create a new business record. There are paid expedite services, but the free route is fine if you start early.
- **Where:** Apple provides a free D-U-N-S lookup/request tool — see [Apple's D-U-N-S help page](https://developer.apple.com/help/account/membership/D-U-N-S/). You can also request directly from [Dun & Bradstreet](https://www.dnb.com/).
- **What you'll provide:** Legal entity name (**A Fair Resolution, LLC** — exactly as registered), registered business address, phone number, and contact name.

> **Critical:** The legal name and address you give Dun & Bradstreet must **exactly match** what you later enter in Apple Developer and Google Play (and in Google's payments profile). Mismatches are the #1 cause of rejected/delayed verifications. Keep the D&B record, your LLC registration, and your store accounts perfectly consistent.

Apple does **not** accept DBAs, fictitious/trade names, or branches — the account must be the legal entity itself. Your LLC qualifies.

---

## 2. Apple App Store: open the Apple Developer Program account

### 2.1 What it is and what it costs

- **Apple Developer Program** membership: **$99 USD / year, recurring.** It does **not** auto-stop; if you let it lapse, your app is removed from the App Store. Budget for this annually, indefinitely.
- Enroll as an **Organization** (not Individual), so the app is published under "A Fair Resolution, LLC" rather than a person's name. Organization enrollment is what requires the D-U-N-S number from §1.
- Nonprofits, accredited educational institutions, and government entities can request a **fee waiver**. If A Fair Resolution qualifies as any of these, apply for the waiver during enrollment.

### 2.2 What you need before you start

1. The **D-U-N-S number** from §1.
2. An **Apple ID** for the company (recommend creating a dedicated one like `appdev@afairresolution.com`, *not* a personal Apple ID) with **two-factor authentication enabled**.
3. **Legal authority to bind the company.** Apple requires that the person enrolling has the legal authority to sign contracts on behalf of the LLC (e.g., owner, officer, or someone authorized in writing). Apple may **phone you to verify** this during enrollment.
4. A company **website** and a **work email** at that domain (see §6).

### 2.3 Steps you take

1. Enroll at [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll/) — choose **Company / Organization**.
2. Enter the legal entity name and D-U-N-S; complete Apple's identity verification (possible phone call).
3. Pay the $99 fee.
4. Once approved, sign in to [App Store Connect](https://appstoreconnect.apple.com) — this is where the app lives.
5. In **Agreements, Tax, and Banking**, accept the current **Apple Developer Program License Agreement**. (Kapok is free, so you don't need the Paid Apps agreement or banking details. If you ever charge or add in-app purchases, you'll need to accept the Paid Apps agreement and complete tax + banking forms.)

### 2.4 Grant the engineer access (so §15 can proceed)

You, the enrolling person, become the **Account Holder** — keep that role; it can't be transferred without a process. Then add the engineer in **App Store Connect → Users and Access**:

- Give the engineer the **Admin** or **App Manager** role so they can create the app record, manage builds, and upload to TestFlight. **Developer** role is the minimum for uploading builds.
- The engineer will need to be on the team to create the **distribution certificate** and **provisioning profile** referenced in §15 (2.3).

> **Reviewer demo account:** Apple's reviewers must be able to log in. The engineer will supply Apple with the existing test credentials (e.g., `admin@test.com` / `test123` from the handoff doc). Confirm you're comfortable leaving a working demo login active for review.

---

## 3. Google Play: open the Google Play Developer account

### 3.1 What it is and what it costs

- **Google Play Developer registration:** **$25 USD, one-time** (not annual — unlike Apple).
- Register as an **Organization** account so the app publishes under A Fair Resolution, LLC. As of Google's 2024 rules, **new organization accounts also require a D-U-N-S number** (from §1) plus website and identity verification.

### 3.2 What you need before you start

1. The **D-U-N-S number** from §1 — the legal name and address must match your **Google payments profile** exactly.
2. A **Google account** for the company (recommend a dedicated workspace account, not a personal Gmail).
3. A verifiable **company website** and a **contact email + phone** that Google can confirm.
4. Government-org exception: if A Fair Resolution is a recognized government agency, the D-U-N-S requirement may be waived — but assume you need it.

### 3.3 Steps you take

1. Register at [play.google.com/console](https://play.google.com/console) — select **Organization**.
2. Complete **developer identity verification**: legal name, address, D-U-N-S, website, and a contact email/phone. Google may take days to verify.
3. Pay the $25 fee.
4. Set up the **Google payments profile** (legal name/address matching D&B). Kapok is free, so no bank account is required, but the payments profile identity must still be completed and verified.
5. Note Google's public-listing rule: your **verified contact details and developer name are shown publicly** on the Play listing. Use the business address/email you're comfortable publishing.

> **New-account closed-testing rule:** Google requires *some* new developer accounts (especially personal ones) to run a **closed test with ≥12 testers for ≥14 days** before they can publish to production. Organization accounts are sometimes exempt, but plan for the possibility — recruit ~12 friendly testers (team members, colleagues) in advance so this doesn't surprise you. The engineer manages the test track; you may need to nominate the testers.

### 3.4 Grant the engineer access

In **Play Console → Users and permissions**, add the engineer with **Admin** access (or app-scoped permissions to manage releases and store listing). You remain the account owner.

---

## 4. Decide and approve the app's identity

A few one-time decisions are yours to make. The engineer needs these *before* building (they feed §15's bundle-ID and Firebase work):

- **Reverse-DNS app identifier.** The engineer recommends something like `org.afairresolution.kapok` or `com.afairresolution.kapok`. This becomes permanent on Google Play and effectively permanent on Apple — **it cannot be changed after first publish.** Confirm the exact string with the engineer. Ideally it's based on a domain you own (§6).
- **Public app name.** "Kapok" — confirm this is final and that you have the right to use it (check it's not trademarked by someone else in the app categories; a quick search of both stores for "Kapok" is prudent).
- **Developer/publisher display name** shown on both listings — confirm "A Fair Resolution, LLC" or a chosen public brand name.
- **Price & countries:** Confirm Kapok is **free** and decide which **countries/regions** it's distributed in (default: all available).

---

## 5. Transfer ownership of the cloud services to your company

These services currently power the app and likely sit under a developer's personal account today. For a real handoff, ownership and billing should move to **your company's** Google identity so you control them long-term and aren't dependent on any individual.

### 5.1 Firebase / Google Cloud (backend, auth, database, crash reporting)

- Ensure the **Firebase project** is owned by your company Google account and that **billing** (if any paid tier is used) is on a company card.
- The engineer handles the technical reconfiguration (re-registering bundle IDs, API key restrictions — §15 2.1, 2.7). You provide the company Google account and act as **Owner**, then grant the engineer Editor/Owner access as needed.

### 5.2 Mapbox (the map)

- The app uses **Mapbox**, which is a **separate paid service** with its own account and billing. Maps usage is free up to a monthly limit, then billed per use.
- **Action:** Create/own a **Mapbox account** under the company, add a company payment method, and set a **billing alert / usage cap** so a traffic spike can't generate a surprise bill. The engineer needs the production access token from this account (§15 2.4).
- Decide who owns this account long-term — it should be the company, not an individual engineer.

> **Why this matters:** If these accounts stay under a contractor's personal login and that relationship ends, you could lose control of your own app's backend and maps. Put them under the company now.

---

## 6. Stand up a website, support email, and legal pages

Both stores **require a public Privacy Policy URL** and a **support contact** before you can publish. These are content/legal items only you can authorize.

### 6.1 Domain, hosting, and email

- **Own a domain** (e.g., `afairresolution.com`) if you don't already. The app identifier (§4) and your store-listing URLs ideally live here.
- Set up a **support email** (e.g., `support@afairresolution.com`) — required on both store listings and shown publicly.
- You need somewhere to **host two web pages**: the Privacy Policy and the Terms of Service. Any simple website/host works; the engineer can publish the pages, but **you must supply and approve the content.**

### 6.2 Privacy Policy & Terms of Service (legal content)

The app currently has placeholder stubs (§15 2.6). A real, hosted, dated Privacy Policy is **mandatory** — Google won't even let you start testing without the URL, and Apple's App Privacy section depends on it.

**You must decide/approve the content.** It must accurately describe what Kapok does. Based on the app's actual behavior, the policy needs to disclose:

- **Data collected:** email, password (securely hashed by Firebase), display name, user role, team membership, the content of tasks users create, **device location when creating a task**, and language preference.
- **Who it's shared with:** Google/Firebase (backend), Mapbox (map/geocoding only — never user identity), and crash reporting.
- **How users delete their account/data**, and the retention period.
- **Children:** state that Kapok is **not directed at children**.
- A **contact email** at A Fair Resolution, LLC, and a **last-updated date**.

> **Recommendation:** Because this is a legal document covering location and personal data, have a lawyer (or at minimum a reputable policy generator reviewed by counsel) prepare the Privacy Policy and Terms of Service. The engineer can draft a technically-accurate first pass for your lawyer to review, but the final text is your legal responsibility, not the engineer's. If Kapok will ever be used in the EU/UK, GDPR adds further requirements — flag this to counsel.

---

## 7. Provide and approve the store-listing content

The stores display marketing content that you should write or approve (the engineer can format and upload it, but the messaging and brand are yours):

| Item | Apple | Google Play | Notes |
| --- | --- | --- | --- |
| Short description | — | ≤80 chars | One-line pitch |
| Full description | ≤4000 chars | ≤4000 chars | What Kapok does |
| Promotional text | ≤170 chars | — | Apple only |
| Keywords | ≤100 chars | (baked into description) | App-store search |
| Screenshots | ≥3–5 per device size | 2–8 phone (+ tablet) | Engineer captures; **you approve** they look right and aren't misleading |
| App icon | 1024×1024 | 512×512 | Already designed; confirm final |
| Feature graphic | — | 1024×500 (**required**) | Banner at top of Play listing |
| Support URL / email | Required | Required | From §6 |
| Marketing URL | Optional | Optional | Your website |
| Category | You choose | You choose | Suggested: **Productivity** or **Utilities** |
| Copyright line | Required | — | e.g., "© 2026 A Fair Resolution, LLC" |

> **Truth-in-advertising:** Apple rejects listings that advertise features the app doesn't actually deliver (Guideline 2.3). Only describe what Kapok really does. Coordinate the description with the engineer so it matches the shipped build.

---

## 8. Answer the compliance questionnaires (business decisions)

Both stores make you answer questionnaires that are **business/legal attestations** — you should review and own these answers, even if the engineer fills in the form:

- **Apple App Privacy ("nutrition label")** and **Google Play Data Safety form.** These must match your Privacy Policy (§6.2). They declare that the app collects email, location, user-generated content, user ID, analytics/usage, and crash diagnostics. The engineer can pre-fill from the code, but you're attesting the answers are true.
- **Age / content rating questionnaire** (Apple's rating + Google's IARC). Kapok will land at a low/general rating, but because users create their own task content, you must answer the **user-generated-content** questions honestly. Do **not** mark the app as child-directed.
- **Target audience & "government/official" positioning.** If you describe Kapok as an official disaster-response tool, expect **stricter store review**. Decide how you want to position it.
- **Export compliance (Apple).** You'll be asked whether the app uses encryption. Standard HTTPS/Firebase usually qualifies for an exemption — confirm the answer with the engineer.

---

## 9. Ongoing responsibilities after launch

Owning published apps is not "set and forget":

- **Renew the Apple membership every year ($99).** Miss it and the app is pulled from the App Store. (Google's $25 is one-time — no renewal.)
- **Keep accounts in good standing:** Google and Apple periodically re-verify identity; respond to their emails or the account can be suspended.
- **Respond to user reviews and ratings** on both stores.
- **Keep contact info, Privacy Policy, and D-U-N-S record accurate** as the business changes.
- **Watch for store policy changes** — both stores email policy deadlines (e.g., new API targets, data-form updates) that require the engineer to act, but the notices come to *your* account.
- **Watch the Mapbox bill** (§5.2) and any Firebase paid usage.

---

## 10. Cost & timeline summary

| Item | Cost | Frequency | Lead time |
| --- | --- | --- | --- |
| D-U-N-S number | Free | One-time | **Days to ~30 days** — start first |
| Apple Developer Program | $99 USD | **Per year** | Hours to days after D-U-N-S; possible verification call |
| Google Play registration | $25 USD | One-time | Days (identity verification) |
| Domain + email + page hosting | ~$10–50 USD/yr typical | Ongoing | Hours |
| Privacy Policy / ToS (lawyer, optional but advised) | Varies | One-time + updates | Days to weeks |
| Mapbox usage | Usage-based (free tier, then metered) | Ongoing | Account setup is minutes |

**Realistic sequencing:**

1. **Week 0:** Start D-U-N-S. Secure domain + company Google/Apple IDs + support email.
2. **While D-U-N-S processes:** Draft Privacy Policy / ToS with counsel; write store descriptions; decide app identifier, name, category, countries.
3. **D-U-N-S in hand:** Open Apple Developer ($99) and Google Play ($25) org accounts; grant the engineer access.
4. **Accounts live:** Engineer executes the technical work in §15 (signing, builds, uploads), captures screenshots for your approval.
5. **Beta:** TestFlight (Apple) + Play internal/closed testing (recruit ~12 testers — §3.3) for a dogfood cycle.
6. **Submit → review → public launch.**

---

## 11. Your checklist

**Foundational (do first):**

- [ ] Request the **D-U-N-S number** for A Fair Resolution, LLC.
- [ ] Confirm the **exact legal name + address** that will be used everywhere (D&B, Apple, Google).
- [ ] Secure a **company domain**, **support email**, and a place to **host two web pages**.
- [ ] Create **company Apple ID** and **company Google account** (with 2FA), not personal ones.

**Accounts & money:**

- [ ] Enroll in **Apple Developer Program** (Organization, $99/yr) once D-U-N-S is ready.
- [ ] Register **Google Play Developer** (Organization, $25) once D-U-N-S is ready.
- [ ] Accept Apple's **Developer Program License Agreement**; complete Google's **payments profile**.
- [ ] Set up and **billing-cap the Mapbox** account under the company.
- [ ] Confirm **Firebase/Google Cloud** project + billing are under the company.
- [ ] **Grant the engineer access** (App Store Connect + Play Console + Firebase + Mapbox token).

**Content & legal (yours to provide/approve):**

- [ ] Approve final **app identifier**, **app name**, **publisher name**, **category**, **price (free)**, **countries**.
- [ ] Provide/approve **Privacy Policy** + **Terms of Service** (lawyer-reviewed) and host them.
- [ ] Write/approve **store descriptions**, **keywords**, and **approve screenshots** the engineer captures.
- [ ] Review and own the **App Privacy / Data Safety** answers and **age-rating** questionnaire.
- [ ] Decide whether to position Kapok as an **official** tool (affects review scrutiny).

**Ongoing:**

- [ ] Calendar reminder to **renew Apple membership annually**.
- [ ] Assign someone to **respond to reviews** and **monitor Mapbox/Firebase billing**.

---

## 12. References

- Apple — D-U-N-S Number help: https://developer.apple.com/help/account/membership/D-U-N-S/
- Apple — Program enrollment: https://developer.apple.com/help/account/membership/program-enrollment/
- Apple Developer Program (enroll): https://developer.apple.com/programs/enroll/
- App Store Connect: https://appstoreconnect.apple.com
- Google Play — required info to create a developer account: https://support.google.com/googleplay/android-developer/answer/13628312
- Google Play — verify developer identity: https://support.google.com/googleplay/android-developer/answer/10841920
- Google Play Console: https://play.google.com/console
- Dun & Bradstreet: https://www.dnb.com/
- Companion engineering doc: [`15_store_readiness_evaluation.md`](15_store_readiness_evaluation.md)
