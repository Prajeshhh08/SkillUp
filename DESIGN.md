# SkillUp Mobile Application Flow & Design System

## Project Overview
- **Project Name:** SkillUp (Emerald Cooperative App Interface)
- **Primary Stitch Project ID (Onboarding/Auth):** `3860065034183508668`
- **Customer Discovery & Booking Stitch Project ID:** `14570061873123891247`
- **Customer Fulfillment & Order Lifecycle Stitch Project ID:** `15166046803774944096`
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

### 1. Onboarding & Worker Setup Flow (`Project ID: 3860065034183508668`)

| # | Screen Name | Route Path | Stitch Screen ID | Description & Visual Details |
|---|---|---|---|---|
| 1 | Login / Authentication | `/login` | `14829376d7d04469b19ff7cf12606c4e` | Sign in screen with Role toggle (Customer/Worker), phone/email inputs, and action buttons. |
| 2 | Terms & Privacy Policy | `/terms` | `daaf48ed285343cdbcedb586e17eee10` | Full terms of service text, privacy agreements, and acceptance action buttons. |
| 3 | Home / Service Discovery | `/home` | `514fb66664c0472e91f382e77e4526f9` | Worker dashboard with search bar, active bookings, and bottom navigation. |
| 4 | Worker Onboarding / Info | `/worker-onboarding` | `2e4b84779d874ca480d67615e3bccdd3` | Skill registration form for workers entering preferred work categories. |
| 5 | Worker Professional Details | `/worker-details` | `a92a632745b442e38af4fdd3d4758ecc` | Detailed registration form including experience, verification uploads, and bank payment details. |
| 6 | Worker Join Network | `/worker-join` | `d68a704b9fa445c9835518c7d53fa28a` | Landing screen inviting workers to join the platform. |
| 7 | Verification Pending | `/verification-pending` | `54d8a729a22745559da4892f3da06f17` | Status screen showing background verification in progress by the admin team. |
| 8 | OTP Verification | `/otp` | `e49b058c0f234f3e97225cc916882c31` | 6-digit pin input screen for phone/email verification. |
| 9 | Customer Sign Up | `/customer-signup` | `3edff1f604ea43c0ae17e5bd88fd70ef` | Name, email, phone number, and password entry form for customers. |
| 10 | Worker Sign Up | `/worker-signup` | `be15cb17f00c4ed9b333c39fec566d88` | Specialized registration form for skilled workers. |
| 11 | Worker Verification Status | `/worker-status` | `9964bdc1bf934b578710f1dadf002f8c` | Status indicator view for pending approvals and background checks. |
| 12 | Worker Professional Form | `/worker-form` | `1b7b469a1fda4ac298067ff13e99aa3c` | Full-length form covering bio, skill categories, and payout information. |
| 13 | Address Setup | `/address` | `1b1a60ff15de46e885e54dd6ccff71f8` | Location search, map preview, and detailed address tags (Home, Work, Other). |
| 14 | Forgot Password | `/forgot-password` | `a15ab65d9efa4dc48c1ee4c257954893` | Reset password screen requesting email or registered phone number. |
| 15 | Customer Dashboard | `/customer-home` | `559502ee343b4596b09f6e6a077c9b53` | Landing dashboard with search bar, popular categories, and quick booking triggers. |
| 16 | Terms Confirmation | `/terms-confirm` | `424c8885fb164ec7a160cebcb6f9a846` | Secondary terms and condition review screen before account finalization. |

---

### 2. Customer Discovery & Booking Flow (`Project ID: 14570061873123891247`)

| # | Screen Name | Route Path | Stitch Screen ID | Description & Visual Details |
|---|---|---|---|---|
| 17 | Service Categories | `/categories` | `0ac6538bcd5543f98a91f7fc4ab818ed` | Grid layout displaying all service categories (Plumbing, Electrical, Cleaning, etc.). |
| 18 | Service Listing | `/services` | `237f4178c047407b940b5392c1db512e` | Filterable list of services within a category showing pricing and duration. |
| 19 | Service Details | `/service-details` | `658b6362650343edadc388f4606dbed9` | Detailed breakdown of inclusions, exclusions, starting costs, and "Book Now" CTA. |
| 20 | Search / Filter | `/search` | `6d308c32b8864222a13c9d8ee0a72856` | Search page with filter chips for ratings, distance, immediate availability, and price. |
| 21 | Nearby Workers List | `/nearby-workers` | `781d255e63854c41b984cb25b0c73678` | List view of local verified workers with ratings, distances, and map view toggle. |
| 22 | Map Matching | `/map-matching` | `9661500822ad481c8d1e0e4309f0dcf9` | Full interactive map screen with worker pin markers and pop-up profile cards. |
| 23 | Worker Profile | `/worker-profile` | `d7e9a63a6e754762801096dad007d6d1` | Worker bio, skill badges, verification badges, user reviews, and "Book Worker" CTA. |
| 24 | Emergency Booking | `/emergency-booking` | `dd011397e8064158b496fe955f91a725` | High-priority screen for urgent, immediate service dispatch requests. |
| 25 | Booking Schedule | `/booking-schedule` | `f5e1107e95bf4c62893ce1d99e13b7c3` | Date picker and time slot selection chips (Morning, Afternoon, Evening). |
| 26 | Booking Review | `/booking-review` | `fe3610ed57af4c9c8b2c3087f46683ef` | Final review screen with itemized billing summary, address summary, and confirmation CTA. |

---

### 3. Customer Fulfillment & Order Lifecycle Flow (`Project ID: 15166046803774944096`)

| # | Screen Name | Route Path | Stitch Screen ID | Description & Visual Details |
|---|---|---|---|---|
| 27 | Booking Address Selection | `/booking-address` | `518644b0f5b94fb995935f0cc7e77152` | Address selection list with saved addresses, landmark entry, and add-address trigger. |
| 28 | Booking Confirmation | `/booking-confirmation` | `62b28d1d74664036bdd6292c5950e53f` | Confirmation indicator displaying Booking ID, pending status, and tracking CTA. |
| 29 | Active Booking Tracking | `/active-booking` | `84d74326e88a4b459c0dc9e73c9da2bf` | Real-time tracking timeline, worker info card, call/chat actions, and cancel/reschedule actions. |
| 30 | Cancel / Reschedule | `/cancel-reschedule` | `9344e079a0c346c3b41b392af623e093` | Reason selection, date/time rescheduling slots, and cancellation policy warning. |
| 31 | Payment Checkout | `/payment-checkout` | `98b9aabb1dc34e5792ec6be94fa73d0d` | Checkout screen with payment method options (UPI, Card, NetBanking) and total payable amount. |
| 32 | Invoice & Payment Success | `/invoice` | `a9027e7ae6764598b9d87ad66e5e1e0b` | Itemized invoice breakdown, cooperative/welfare contribution split, and download receipt option. |
| 33 | Rating & Review | `/rating-review` | `b917350fe0ed46949d67f236037ad8ae` | Interactive star rating, quick feedback tags, review text area, and submit CTA. |
| 34 | Booking History | `/booking-history` | `cb5e262de2a649e0b6ffd2c2797a158d` | Tabbed view (Active, Completed, Cancelled) with rebook and invoice view triggers. |
| 35 | Rebook Service | `/rebook` | `489fc445467c43738c37ea599fdcc0d4` | Quick re-order view pre-filled with past service specs, allowing schedule and location updates. |
| 36 | Service Address Setup | `/service-address` | `81d34665202a4db1af1550713f20635a` | Dedicated service location selector for recurring or specific booking needs. |
| 37 | Order Details / Summary | `/order-summary` | `ebd1b81ca9ae4e0497af8ececee25e83` | High-level overview of active or completed order status with support actions. |

---

## Complete Route Configuration (`lib/router/app_router.dart`)

```dart
// Flow 1: Auth, Onboarding & Management
'/login'                -> LoginScreen()
'/terms'                -> TermsAndPrivacyScreen()
'/home'                 -> HomeScreen()
'/worker-onboarding'    -> WorkerOnboardingScreen()
'/worker-details'       -> WorkerDetailsScreen()
'/worker-join'          -> WorkerJoinScreen()
'/verification-pending' -> VerificationPendingScreen()
'/otp'                  -> OtpScreen()
'/customer-signup'      -> CustomerSignupScreen()
'/worker-signup'        -> WorkerSignupScreen()
'/worker-status'        -> WorkerStatusScreen()
'/worker-form'          -> WorkerFormScreen()
'/address'              -> AddressSetupScreen()
'/forgot-password'      -> ForgotPasswordScreen()
'/customer-home'        -> CustomerHomeScreen()
'/terms-confirm'        -> TermsConfirmScreen()

// Flow 2: Customer Discovery & Booking Journey
'/categories'           -> CategoriesScreen()
'/services'             -> ServiceListingScreen()
'/service-details'      -> ServiceDetailsScreen()
'/search'               -> SearchFilterScreen()
'/nearby-workers'       -> NearbyWorkersScreen()
'/map-matching'         -> MapMatchingScreen()
'/worker-profile'       -> WorkerProfileScreen()
'/emergency-booking'    -> EmergencyBookingScreen()
'/booking-schedule'     -> BookingScheduleScreen()
'/booking-review'       -> BookingReviewScreen()

// Flow 3: Customer Fulfillment & Order Lifecycle
'/booking-address'      -> BookingAddressScreen()
'/booking-confirmation' -> BookingConfirmationScreen()
'/active-booking'       -> ActiveBookingTrackingScreen()
'/cancel-reschedule'    -> CancelRescheduleScreen()
'/payment-checkout'     -> PaymentCheckoutScreen()
'/invoice'              -> InvoiceSuccessScreen()
'/rating-review'        -> RatingReviewScreen()
'/booking-history'      -> BookingHistoryScreen()
'/rebook'               -> RebookScreen()
'/service-address'      -> ServiceAddressScreen()
'/order-summary'        -> OrderSummaryScreen()