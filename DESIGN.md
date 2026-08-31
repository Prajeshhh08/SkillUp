# SkillUp Mobile Application Flow & Design System

## Project Overview
- **Project Name:** SkillUp (Emerald Cooperative App Interface)
- **Stitch Project ID:** `3860065034183508668`
- **Primary Color:** Deep Emerald (`#145C4C`)
- **Primary Fill / Container:** Mint Soft (`#E8F4F1`)
- **Background:** Pure White (`#FFFFFF`)
- **Surface / Inputs:** Soft Neutral Light (`#F8FAF9`)
- **Text Primary:** Charcoal Dark (`#111827`)
- **Text Secondary:** Cool Muted Gray (`#6B7280`)
- **Border & Dividers:** Subtle Gray (`#E5E7EB`)
- **Corner Radius:** Universal 12dp (8dp-16dp scale)
- **Typography:** `GoogleFonts.inter`

---

## Screen Inventory & Visual Specs

| # | Screen Name | Route Path | Stitch Screen ID | Description & Visual Details |
|---|---|---|---|---|
| 1 | Login / Authentication | `/login` | `14829376d7d04469b19ff7cf12606c4e` | Sign in screen with Role toggle (Customer/Worker), phone/email inputs, and action buttons. |
| 2 | Terms & Privacy Policy | `/terms` | `daaf48ed285343cdbcedb586e17eee10` | Full terms of service text, privacy agreements, and acceptance action buttons. |
| 3 | Home / Service Discovery | `/home` | `514fb66664c0472e91f382e77e4526f9` | Home dashboard with search bar, service categories, active bookings, and bottom navigation. |
| 4 | Worker Onboarding / Info | `/worker-onboarding` | `2e4b84779d874ca480d67615e3bccdd3` | Skill registration form for workers entering preferred work categories. |
| 5 | Worker Professional Details | `/worker-details` | `a92a632745b442e38af4fdd3d4758ecc` | Detailed registration form including experience, verification uploads, and bank payment details. |
| 6 | Worker Join Network | `/worker-join` | `d68a704b9fa445c9835518c7d53fa28a` | Landing screen inviting workers to join the platform. |
| 7 | Verification Pending | `/verification-pending` | `54d8a729a22745559da4892f3da06f17` | Status screen showing background verification in progress by the admin team. |
| 8 | OTP Verification | `/otp` | `e49b058c0f234f3e97225cc916882c31` | 6-digit pin input screen for phone/email verification. |
| 9 | Customer Sign Up | `/customer-signup` | `3edff1f604ea43c0ae17e5bd88fd70ef` | Name, email, phone number, and password entry form for customers. |
| 10 | Worker Sign Up | `/worker-signup` | `be15cb17f00c4ed9b333c39fec566d88` | Specialized registration form for skilled workers. |
| 11 | Worker Verification Status | `/worker-status` | `9964bdc1bf934b578710f1dadf002f8c` | Duplicate status indicator view for pending approvals. |
| 12 | Worker Professional Form | `/worker-form` | `1b7b469a1fda4ac298067ff13e99aa3c` | Full-length form covering bio, skill categories, and payout information. |
| 13 | Address Setup | `/address` | `1b1a60ff15de46e885e54dd6ccff71f8` | Location search, map preview, and detailed address tags (Home, Work, Other). |
| 14 | Forgot Password | `/forgot-password` | `a15ab65d9efa4dc48c1ee4c257954893` | Reset password screen requesting email or registered phone number. |
| 15 | Customer Dashboard | `/customer-home` | `559502ee343b4596b09f6e6a077c9b53` | Alternative customer home view with service cards and quick search. |
| 16 | Terms Confirmation | `/terms-confirm` | `424c8885fb164ec7a160cebcb6f9a846` | Secondary terms and condition review screen before account finalization. |

---

## Route Configuration
- `/login` -> `LoginScreen`
- `/terms` -> `TermsAndPrivacyScreen`
- `/home` -> `HomeScreen`
- `/worker-onboarding` -> `WorkerOnboardingScreen`
- `/worker-details` -> `WorkerDetailsScreen`
- `/worker-join` -> `WorkerJoinScreen`
- `/verification-pending` -> `VerificationPendingScreen`
- `/otp` -> `OtpScreen`
- `/customer-signup` -> `CustomerSignupScreen`
- `/worker-signup` -> `WorkerSignupScreen`
- `/worker-status` -> `WorkerStatusScreen`
- `/worker-form` -> `WorkerFormScreen`
- `/address` -> `AddressSetupScreen`
- `/forgot-password` -> `ForgotPasswordScreen`
- `/customer-home` -> `CustomerHomeScreen`
- `/terms-confirm` -> `TermsConfirmScreen`