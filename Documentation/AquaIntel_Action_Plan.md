# AquaIntel – Final-Year Project Action Plan & Remaining Work

**Project Title:** AquaIntel: A Domain-Specific AI System for Smart Aquarium Management  
**Status:** In Progress (Undergoing Incremental Testing & Report Preparation)  
**Historical Development Baseline:** 10 September 2026 – 05 November 2026  
**Post-Period Iteration:** 09 November 2026 (`Commit 4acf4f7`)  
**Target Milestone:** Comprehensive Release Candidate Freeze -> University Final Project Submission (Date Pending Confirmation)

---

## 1. Project Status Overview

The AquaIntel application architecture, FastAPI backend, core multi-aquarium CRUD, rule-based Fish Compatibility Checker, AquaBot AI engine, and community data models have been developed and initially integrated. 

In strict adherence to academic integrity:
- **Core feature implementation** is largely completed.
- **System and module testing** are **ongoing** across multi-device configurations.
- **Reflective Report review and final report compilation** are **ongoing**.
- **The project has NOT yet been submitted.** Full integration testing, final system testing, and formal demonstration preparation are **planned future activities**.

---

## 2. Action Plan Log – Remaining Work

| ID | Remaining Task / Deliverable | Scope of Work & Verification Protocol | Priority | Current Status | Target Completion |
|---|---|---|---|---|---|
| **AP-01** | **Verify Fish Compatibility Database Records** | Review Firestore compatibility rules and verify that pairwise parameter matrices (pH, temperature tolerance, aggressive/peaceful behavior) are fully seeded and validated against aquarium reference standards. | High | In Progress | 2026-11-09 |
| **AP-02** | **Complete AquaBot Response Testing** | Execute `backend/test_ai.py` validation harness. Test boundary handling for out-of-scope queries (e.g. general non-aquarium questions), latency benchmarks, and hallucination reduction prompts. | High | In Progress | 2026-11-10 |
| **AP-03** | **Test Firebase Integration & Security Rules** | Publish and verify partitioned `firestore.rules` (public profile document read access for author avatars vs strict owner-only subcollections: `aquariums`, `reminders`, `settings`). | High | In Progress | 2026-11-08 |
| **AP-04** | **Verify Community Features & Avatar Display** | Test `AuthorAvatar` widget across multiple accounts. Verify in-memory avatar caching, shared stream listener deduplication, and graceful initials fallback when network is unavailable. | High | In Progress | 2026-11-11 |
| **AP-05** | **Complete Reminder & Notification Testing** | Test exact alarm scheduling via `flutter_local_notifications` on Android 12, 13, and 14+. Validate foreground/background wakeups, notification taps navigating to Maintenance screen, and overdue state persistence. | Medium | In Progress | 2026-11-09 |
| **AP-06** | **Conduct Full Application Integration Testing** | Perform end-to-end integration walkthrough: User Sign Up -> Aquarium Profile Creation -> Custom Reminder Setup -> Pairwise Compatibility Check -> AquaBot Consultation -> Community Feed Post. | High | Planned | 2026-11-14 |
| **AP-07** | **Fix Remaining UI & Functional Bugs** | Resolve remaining RenderFlex overflow warnings on narrow Android screens, verify bottom navigation safe-area insets, and ensure dark theme consistency (`AquaColors.bg`, `AquaColors.card`). | Medium | In Progress | 2026-11-12 |
| **AP-08** | **Update Technical Documentation & Evidence** | Update `Database_Schema.md`, capture comprehensive test pass logs, generate test coverage reports, and format figures for inclusion in dissertation appendices. | Medium | Planned | 2026-11-13 |
| **AP-09** | **Review and Finalise Reflective and Final Reports** | Complete Chapter 5 (Evaluation) and Chapter 6 (Reflective Self-Analysis) of the final thesis. Address supervisor feedback regarding engineering challenges and architectural trade-offs. | High | In Progress | 2026-11-15 |
| **AP-10** | **Prepare Final Project Demonstration** | Seed realistic showcase aquariums (Saltwater Reef, Freshwater Planted, Cichlid Biotope), rehearse live application walkthrough, prepare demonstration slide deck and backup video demo. | High | Planned | 2026-11-16 |
| **AP-11** | **Complete University Submission When Ready** | Conduct final code freeze, archive Git tag release candidate, compile final thesis PDF, and submit required project deliverables through institutional portal upon supervisor approval. | Critical | Planned | Pending Confirmation |

---

## 3. Testing Matrix & Current Status

| Testing Activity | Scope / Components Tested | Status | Findings / Next Steps |
|---|---|---|---|
| **Initial Functional Testing** | Aquarium creation, volume calculation, reminder CRUD, basic auth | **Completed** | Core functionality verified via initial unit tests. |
| **Firebase Auth & Firestore Testing** | Login, registration, token persistence, Firestore security rules | **Ongoing** | Split user document read rules implemented; testing live multi-account isolation. |
| **Aquarium CRUD Verification** | Adding, editing, deleting aquariums, image attachment | **Ongoing** | Basic CRUD verified; testing offline state synchronization. |
| **Fish Compatibility Testing** | Rule engine, pairwise matrix comparisons, warning badge generation | **Ongoing** | Core rules operational; continuing edge-case validation with 15+ species. |
| **AquaBot Response Testing** | Domain AI chat, prompt injection safety, response latency | **Ongoing** | Prompt guardrails working; testing timeout recovery on slower mobile connections. |
| **Community Post/Like/Comment Testing** | Realtime feed, like toggle idempotency, comment bottom-sheet | **Ongoing** | Feed display verified; testing high-concurrency like/comment count streams. |
| **Profile Avatar Display Verification** | 20 3D cartoon avatars, author avatar resolution in feed/comments | **Ongoing** | In-memory cache implemented; conducting cross-user display verification. |
| **Reminder & Notification Testing** | Scheduled task alarms, status toggles, overdue indicators | **Ongoing** | Background notification firing verified; fine-tuning Android battery optimization settings. |
| **UI Responsiveness & Layout Testing** | Reminder card width/height constraints, badge wrapping | **Ongoing** | Fixed 21px horizontal and 1.4px vertical overflow in reminder card; ongoing small-screen audit. |
| **Application Integration Testing** | End-to-end data flow between backend, Firestore, and UI | **Planned** | Scheduled following completion of component-level verification. |
| **Final System Testing** | Performance profiling, memory leak detection, build release check | **Planned** | Scheduled prior to final code freeze. |
| **Bug Fixing & Final Refinements** | Static analysis zero-warning verification (`flutter analyze`) | **Ongoing** | Current status: 0 errors, 0 warnings. Maintaining clean lint state. |

---

## 4. Reflective Report Development Timeline

The **Reflective Report Writing and Improvement** activity was initiated during the mid-project development cycle (14 October 2026) to systematically capture:
1. Technical challenges encountered during mobile background notification scheduling.
2. The evolution from general AI queries to a domain-bounded aquarium assistant architecture.
3. Firestore security rule constraints regarding cross-user avatar visibility in community posts.
4. Evaluation of Agile iteration cycles versus initial project milestones.

Review and finalization of the reflective report remain **Ongoing** and will conclude alongside the final dissertation submission.
