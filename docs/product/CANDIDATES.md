Here is a ranked strategic proposal for 5 native, on-device iPhone app concepts designed for a solo developer to build and ship in 10 working days (2 weeks).

---

### **1. PurgeSwipe: Local Photo & Duplicate Storage Cleaner**
* **Job-to-be-Done:** Free up gigabytes of iPhone storage in minutes by swiping through duplicate, blurry, and screenshot photos offline.
* **Target User & Moment:** Storage-starved iPhone users opening the app immediately after receiving an iOS *"Storage Almost Full"* system warning.
* **Core Loop:** Trigger (storage warning) \\(\rightarrow\\) Action (swipe left to trash, right to keep) \\(\rightarrow\\) On-device processing (Vision framework groups duplicates/blur) \\(\rightarrow\\) Visible result (freed GB counter) \\(\rightarrow\\) Reason to return (weekly storage audit widget notification).
* **3 Screens:** 1) Swipe Deck Clean View; 2) Storage Summary & Bulk Trash Bin; 3) Settings / Hybrid Paywall.
* **Apple Frameworks:** PhotosUI, Vision (`VNRecognizeTextRequest` & image similarity), SwiftData, StoreKit 2.
* **Competitor Pricing (EVIDENCE):** Competitor photo cleaners charge ~\$10/week (\$9.99/wk) subscriptions [1, 2].
* **10-Day Solo Feasibility (INFERENCE):** `PHFetchResult` + SwiftUI card swipe gesture takes ~3 days; local Vision blur/similarity checks take 2 days; StoreKit 2 paywall takes 2 days; testing takes 3 days.
* **App Review Risk & Mitigation:** Guideline 5.1.1 (Photo Privacy). *Mitigation:* Explicit Info.plist privacy description emphasizing 100% on-device processing with zero network calls.
* **Ad Placement:** Native banner ad embedded on the Trash Confirmation screen after batch swiping, keeping the main card swipe gesture completely ad-free.
* **Recommended Price Points (EVIDENCE + INFERENCE):** \$2.99/wk, \$19.99/yr, \$29.99 lifetime. *Anchors:* US median weekly price is \$6.99 [3]; low-priced annual plans retain 36% in Year 1 vs 23% for high-priced plans [4]; Utilities 12-month median trial LTV is \$68.90 [5, 6].

---

### **2. DocQuick PDF: On-Device Document & OCR Scanner**
* **Job-to-be-Done:** Convert paper documents and receipts into searchable, encrypted PDF files on-device in under 5 seconds.
* **Target User & Moment:** Freelancers and students needing to scan and export a document immediately without creating a cloud account.
* **Core Loop:** Trigger (physical paper in hand) \\(\rightarrow\\) Action (camera auto-capture) \\(\rightarrow\\) On-device processing (VisionKit edge detection + Vision OCR text extraction + PDFKit compilation) \\(\rightarrow\\) Visible result (searchable PDF preview) \\(\rightarrow\\) Reason to return (searchable local document archive).
* **3 Screens:** 1) Camera Document Scanner; 2) Document OCR Editor & PDF Preview; 3) Document Grid / Paywall.
* **Apple Frameworks:** VisionKit (`VNDocumentCameraViewController`), Vision, PDFKit, SwiftData, AppIntents.
* **Competitor Pricing (EVIDENCE):** Scanner apps charge \$5.99/week or \$80+/year [7].
* **10-Day Solo Feasibility (INFERENCE):** `VNDocumentCameraViewController` provides turnkey scanner UI; PDFKit handles PDF compilation in 2 days; SwiftData indexing takes 2 days.
* **App Review Risk & Mitigation:** Guideline 4.2 (Minimum Functionality). *Mitigation:* Include full local text search and OCR export so it functions as a complete local document tool.
* **Ad Placement:** Non-intrusive banner on the Document Archive list view; optional rewarded video ad to unlock batch OCR export beyond 3 docs/day.
* **Recommended Price Points (EVIDENCE + INFERENCE):** \$2.99/wk, \$19.99/yr, \$34.99 lifetime [3-5].

---

### **3. HydroPulse: Zero-Cloud Hydration & Routine Log**
* **Job-to-be-Done:** Log daily water and habit progress in 1 second directly from the Lock Screen or Siri without launching a full app.
* **Target User & Moment:** Desk workers wanting to record water intake instantly throughout the workday.
* **Core Loop:** Trigger (thirst / Lock Screen control button) \\(\rightarrow\\) Action (tap widget / Siri command) \\(\rightarrow\\) On-device processing (`AppIntent` execution & HealthKit sync) \\(\rightarrow\\) Visible result (progress ring updates on Widget) \\(\rightarrow\\) Reason to return (streak ring progress).
* **3 Screens:** 1) Today's Hydration Dashboard; 2) Weekly Trends & History Chart; 3) Goals & Paywall.
* **Apple Frameworks:** AppIntents (`AppShortcutsProvider`), WidgetKit, ControlCenter (`ControlWidgetButton`), HealthKit, SwiftData.
* **Competitor Pricing (EVIDENCE):** Simple habit/water apps charge \$4.99/wk or \$40–\$80/yr [8, 9]. Blake Crosley demonstrated a full production `LogWaterIntent` in ~80 lines of Swift [10].
* **10-Day Solo Feasibility (INFERENCE):** AppIntents implementation takes ~80 lines [10]; SwiftUI ring controls and WidgetKit take 4 days; HealthKit sync takes 2 days.
* **App Review Risk & Mitigation:** Guideline 2.5.1 (HealthKit Usage). *Mitigation:* Add explicit HealthKit permission rationale and smooth graceful fallback if access is denied.
* **Ad Placement:** Small banner at the bottom of the weekly Trends view, keeping widgets and Lock Screen controls 100% ad-free.
* **Recommended Price Points (EVIDENCE + INFERENCE):** \$1.99/wk, \$14.99/yr, \$24.99 lifetime [3, 4].

---

### **4. ReceiptSnap Local: On-Device Private Expense Tracker**
* **Job-to-be-Done:** Automatically extract totals, dates, and vendors from paper receipts to maintain private financial records locally.
* **Target User & Moment:** Business travelers or freelancers making a cash/card purchase and filing an expense immediately.
* **Core Loop:** Trigger (purchase made) \\(\rightarrow\\) Action (snap receipt photo) \\(\rightarrow\\) On-device processing (Vision OCR regex parses date, total, vendor) \\(\rightarrow\\) Visible result (auto-filled expense entry) \\(\rightarrow\\) Reason to return (monthly budget summary & CSV export).
* **3 Screens:** 1) Monthly Expense Feed & Total; 2) Camera Receipt OCR Review; 3) Category Charts / Export & Paywall.
* **Apple Frameworks:** Vision (`VNRecognizeTextRequest`), SwiftData, Swift Charts, StoreKit 2.
* **Competitor Pricing (EVIDENCE):** Expense/task tools ask \$10+/mo [11]; general utility apps charge \$10+/mo or \$100+/yr [11, 12].
* **10-Day Solo Feasibility (INFERENCE):** Regex parsing over Vision OCR text takes 3 days; Swift Charts analytics takes 2 days; SwiftData expense schema takes 2 days.
* **App Review Risk & Mitigation:** Guideline 5.1.1 (Financial Data Privacy). *Mitigation:* Explicit privacy manifest stating 0 financial data leaves the device.
* **Ad Placement:** Top banner unit on the monthly CSV Export screen; primary scan loop remains completely clean.
* **Recommended Price Points (EVIDENCE + INFERENCE):** \$2.99/wk, \$19.99/yr, \$34.99 lifetime [4, 5].

---

### **5. ClipVault: Offline Keyboard Snippet Manager**
* **Job-to-be-Done:** Store and paste frequently used text templates, snippets, and email replies in one tap via a custom keyboard.
* **Target User & Moment:** Customer support reps or job applicants filling out repetitive text fields on mobile.
* **Core Loop:** Trigger (typing repetitive text) \\(\rightarrow\\) Action (switch to ClipVault Keyboard / tap snippet) \\(\rightarrow\\) On-device processing (SwiftData lookup) \\(\rightarrow\\) Visible result (instant text insertion) \\(\rightarrow\\) Reason to return (growing snippet library).
* **3 Screens:** 1) Snippet Manager & Tags; 2) Snippet Editor; 3) Custom Keyboard / Setup & Paywall.
* **Apple Frameworks:** SwiftUI, SwiftData, AppIntents, UIKit (Custom Keyboard Extension), StoreKit 2.
* **Competitor Pricing (EVIDENCE):** Clipboard utilities like Paste transitioned to subscriptions [13]; simple desktop/mobile folder utilities ask \$9.95/mo or \$300 lifetime [14].
* **10-Day Solo Feasibility (INFERENCE):** Basic SwiftUI snippet CRUD takes 3 days; Keyboard Extension communication via shared App Group takes 3 days; AppIntents setup takes 2 days.
* **App Review Risk & Mitigation:** Guideline 2.5.8 (Custom Keyboards). *Mitigation:* Ensure keyboard works smoothly without requiring "Full Access" for basic snippet pasting.
* **Ad Placement:** Native ad unit placed after every 5th snippet in the Snippet Manager list view.
* **Recommended Price Points (EVIDENCE + INFERENCE):** \$1.99/wk, \$14.99/yr, \$24.99 lifetime [4].

---

### **Separation of Evidence vs. Inference**

* **EVIDENCE (Cited Facts from Notebook):**
  * Competitor photo cleaners charge ~\$10/week (\$9.99/wk) [1, 2].
  * 55.4% of 3-day trial cancellations happen on Day 0 [15, 16].
  * Utilities lead 12-month trial LTV (\$68.90) and first-renewal retention (58.1%) [5, 6].
  * Low-priced annual plans retain 36% Year 1 median vs 23% for high-priced plans [4, 17].
  * Hard paywalls convert 5x better than freemium (10.7% vs 2.1% by Day 35) [18, 19].
  * Annual churners rarely return (reactivation is ~5%) [20, 21].
  * Simple utility/productivity tools charging \$10+/mo or \$80–\$129/yr spark heavy subscription fatigue [8, 11-14, 22].
* **INFERENCE (Consultant Reasoning):**
  * On-device Vision and AppIntents allow a solo dev to build zero-server apps in <10 days.
  * Offering a Hybrid Paywall with a fair Lifetime option (\$24.99–\$34.99) captures users fleeing \$10/wk subscriptions [1, 2].

---

### **Concept Comparison Table**

| Concept | Trend Signal | Ease (Solo Dev) | Retention Potential | Monetization Fit | App Review Risk (5=Lowest) | Competition (5=Least Crowded) | Total Score |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1. PurgeSwipe** | 5 | 5 | 3 | 5 | 4 | 2 | **24** |
| **2. DocQuick PDF** | 4 | 4 | 4 | 5 | 4 | 3 | **24** |
| **3. HydroPulse** | 4 | 5 | 4 | 3 | 4 | 2 | **22** |
| **4. ReceiptSnap** | 4 | 3 | 4 | 4 | 4 | 4 | **23** |
| **5. ClipVault** | 3 | 3 | 3 | 4 | 3 | 4 | **20** |

*(Scores rated 1–5; for App Review Risk, 5 = lowest risk; for Competition, 5 = least crowded market)*

---

### **Final Recommendation & Single Strongest Reason**

**Recommendation:** Build and ship **PurgeSwipe** (Photo & Storage Cleaner).

**Single Strongest Reason:** It solves an immediate, highly emotional pain point (*"Storage Almost Full"*) where users want an instant 1-session result [16], directly capitalizing on massive public backlash against competitor \$10/week subscriptions [1, 2] with zero server/API costs.

---
📊 *Want me to draft the exact StoreKit 2 Paywall SwiftUI view or write the App Store description for PurgeSwipe?*
