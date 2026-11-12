"""
Updated Gantt Chart and Schedule Generator for AquaIntel Final-Year Project
Reflecting Accurate Status: Completed (Green), Ongoing (Orange), Planned (Blue/Grey),
and Post-Period Progress (09 Nov Commit Extension).
"""

import os
import datetime
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.patches as mpatches
from matplotlib.lines import Line2D
from reportlab.lib.pagesizes import A4, landscape
from reportlab.pdfgen import canvas

# Master Task Registry with Accurate Status
TASKS = [
    # ─── Phase 1: Planning and Research ──────────────────────────────────────
    {
        "phase": "Phase 1: Planning and Research",
        "code": "1.1",
        "name": "Initial Project Planning & Environment Setup",
        "start": "2026-09-10", "end": "2026-09-15",
        "category": "Planning", "status": "Completed", "progress": 1.0,
        "evidence": "Commit 28f0289 (10 Sep): Initial commit & Flutter repository setup",
        "milestone": False
    },
    {
        "phase": "Phase 1: Planning and Research",
        "code": "1.2",
        "name": "Requirements Gathering & Problem Analysis",
        "start": "2026-09-11", "end": "2026-09-18",
        "category": "Planning", "status": "Completed", "progress": 1.0,
        "evidence": "Contextual Report Ch. 1 & User Survey primary research",
        "milestone": False
    },
    {
        "phase": "Phase 1: Planning and Research",
        "code": "1.3",
        "name": "Literature Review & Domain Research",
        "start": "2026-09-12", "end": "2026-09-21",
        "category": "Documentation", "status": "Completed", "progress": 1.0,
        "evidence": "Commit 61a6abb (16 Sep): Literature Review file & Report",
        "milestone": False
    },
    {
        "phase": "Phase 1: Planning and Research",
        "code": "1.4",
        "name": "Project Folder Structure & Documentation Setup",
        "start": "2026-09-15", "end": "2026-09-18",
        "category": "Planning", "status": "Completed", "progress": 1.0,
        "evidence": "Commit 58d74ba (15 Sep) & 61a6abb (16 Sep)",
        "milestone": False
    },
    {
        "phase": "Phase 1: Planning and Research",
        "code": "M1",
        "name": "★ Milestone: Research & Project Baseline Established",
        "start": "2026-09-16", "end": "2026-09-16",
        "category": "Milestone", "status": "Completed", "progress": 1.0,
        "evidence": "Repository structure initialized with Literature Review and Report framework",
        "milestone": True
    },

    # ─── Phase 2: System Design and Backend ──────────────────────────────────
    {
        "phase": "Phase 2: System Design and Backend",
        "code": "2.1",
        "name": "System Architecture & Database Schema Planning",
        "start": "2026-09-18", "end": "2026-09-24",
        "category": "Design", "status": "Completed", "progress": 1.0,
        "evidence": "Documentation/Database_Schema.md & ER Diagrams",
        "milestone": False
    },
    {
        "phase": "Phase 2: System Design and Backend",
        "code": "2.2",
        "name": "FastAPI Backend Setup & Project Architecture",
        "start": "2026-09-20", "end": "2026-09-23",
        "category": "Backend", "status": "Completed", "progress": 1.0,
        "evidence": "Commit 647361f (22 Sep): Add FastAPI backend setup",
        "milestone": False
    },
    {
        "phase": "Phase 2: System Design and Backend",
        "code": "2.3",
        "name": "Database Connection Layer & Realistic Sample Seeder",
        "start": "2026-09-22", "end": "2026-09-25",
        "category": "Backend", "status": "Completed", "progress": 1.0,
        "evidence": "Commit ba830f7 (23 Sep): DB layer, index setup, seed_data.py",
        "milestone": False
    },
    {
        "phase": "Phase 2: System Design and Backend",
        "code": "2.4",
        "name": "Flutter Application Structure & Routing Setup",
        "start": "2026-09-23", "end": "2026-09-28",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "lib/main.dart, app_routes.dart, theme configuration",
        "milestone": False
    },
    {
        "phase": "Phase 2: System Design and Backend",
        "code": "M2",
        "name": "★ Milestone: Backend API Framework & DB Seeder Operational",
        "start": "2026-09-23", "end": "2026-09-23",
        "category": "Milestone", "status": "Completed", "progress": 1.0,
        "evidence": "FastAPI endpoints and database connection verified",
        "milestone": True
    },

    # ─── Phase 3: Core Application Development ───────────────────────────────
    {
        "phase": "Phase 3: Core Application Development",
        "code": "3.1",
        "name": "UI/UX & Home Screen Development with Settings Widgets",
        "start": "2026-09-24", "end": "2026-09-28",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "Commit 2815aef (26 Sep): Modified home UI & settings widgets",
        "milestone": False
    },
    {
        "phase": "Phase 3: Core Application Development",
        "code": "3.2",
        "name": "Firebase Authentication Integration (Login & Register)",
        "start": "2026-09-26", "end": "2026-09-30",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "Commit c4a084a (30 Sep): Firebase auth in login & registration",
        "milestone": False
    },
    {
        "phase": "Phase 3: Core Application Development",
        "code": "3.3",
        "name": "Aquarium Management Module Architecture",
        "start": "2026-09-27", "end": "2026-10-04",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "lib/models/aquarium_model.dart & aquarium_service.dart",
        "milestone": False
    },
    {
        "phase": "Phase 3: Core Application Development",
        "code": "3.4",
        "name": "Aquarium CRUD Functionality & Associated Screens",
        "start": "2026-09-30", "end": "2026-10-04",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "Commit cd046c7 (04 Oct): Completed Aquarium CRUD functionality",
        "milestone": False
    },
    {
        "phase": "Phase 3: Core Application Development",
        "code": "3.5",
        "name": "Dashboard & Aquarium Information Display",
        "start": "2026-09-28", "end": "2026-10-06",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "lib/widgets/aquarium_card.dart & lib/screens/home.dart",
        "milestone": False
    },
    {
        "phase": "Phase 3: Core Application Development",
        "code": "M3",
        "name": "★ Milestone: Core Aquarium CRUD & Auth Deployed",
        "start": "2026-10-04", "end": "2026-10-04",
        "category": "Milestone", "status": "Completed", "progress": 1.0,
        "evidence": "User authentication and multi-aquarium CRUD fully functioning",
        "milestone": True
    },

    # ─── Phase 4: Main Feature Development ───────────────────────────────────
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.1",
        "name": "Reminder Management Interface & Form Screens",
        "start": "2026-09-24", "end": "2026-10-02",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "Commit 4275216 & 6ca5056 (25 Sep): Reminder UI screens added",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.2",
        "name": "Reminder Scheduling & Notification Engine",
        "start": "2026-10-02", "end": "2026-10-14",
        "category": "Backend/App", "status": "Completed", "progress": 1.0,
        "evidence": "lib/services/reminder_service.dart & notification_service.dart",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.3",
        "name": "Fish Compatibility Checker & Rule-Based Logic Engine",
        "start": "2026-10-01", "end": "2026-10-08",
        "category": "Intelligence", "status": "Completed", "progress": 1.0,
        "evidence": "Commit 86ff4c6 (07 Oct): Firebase connection & compatibility task",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.4",
        "name": "AquaBot Domain-Specific AI Assistant Integration",
        "start": "2026-10-05", "end": "2026-10-18",
        "category": "Intelligence", "status": "Completed", "progress": 1.0,
        "evidence": "backend/ai_service.py & lib/screens/aquabot_screen.dart",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.5",
        "name": "Community Module Architecture & Schema Modeling",
        "start": "2026-10-12", "end": "2026-10-22",
        "category": "Architecture", "status": "Completed", "progress": 1.0,
        "evidence": "Documentation/AquaIntel.md Sec. 32-33 & lib/models/community_post.dart",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.6",
        "name": "Community Posts, Likes & Comments Implementation",
        "start": "2026-10-18", "end": "2026-11-04",
        "category": "Frontend/App", "status": "Completed", "progress": 1.0,
        "evidence": "lib/services/community_service.dart & firestore.rules",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.7",
        "name": "User Profile Architecture & Avatar System Specification",
        "start": "2026-10-26", "end": "2026-11-05",
        "category": "Frontend", "status": "Completed", "progress": 1.0,
        "evidence": "lib/models/user_model.dart & UserService architecture",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "4.8",
        "name": "User Profile Avatar Selection & Dashboard Improvements (Post-Period)",
        "start": "2026-11-06", "end": "2026-11-09",
        "category": "Post-Period", "status": "Post-Period Progress", "progress": 1.0,
        "evidence": "Commit 4acf4f7 (09 Nov): Add 20 avatars, dashboard photo & reminder fixes",
        "milestone": False
    },
    {
        "phase": "Phase 4: Main Feature Development",
        "code": "M4",
        "name": "★ Milestone: Core Feature Set (Reminders, Compatibility, AI) Functional",
        "start": "2026-10-16", "end": "2026-10-16",
        "category": "Milestone", "status": "Completed", "progress": 1.0,
        "evidence": "Core algorithmic and domain intelligence modules functioning",
        "milestone": True
    },

    # ─── Phase 5: Testing and Refinement (Accurate Overlapping Status) ────────
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.1",
        "name": "Initial Functional Testing During Feature Development",
        "start": "2026-10-12", "end": "2026-10-26",
        "category": "Testing", "status": "Completed", "progress": 1.0,
        "evidence": "Automated unit tests in test/ & manual test matrix",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.2",
        "name": "Firebase Authentication & Firestore Testing",
        "start": "2026-10-20", "end": "2026-11-08",
        "category": "Testing", "status": "Ongoing", "progress": 0.65,
        "evidence": "firestore.rules security assertions & cross-user read validation",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.3",
        "name": "Aquarium CRUD Functionality Testing & Verification",
        "start": "2026-10-04", "end": "2026-11-06",
        "category": "Testing", "status": "Ongoing", "progress": 0.85,
        "evidence": "test/aquarium_model_test.dart & multi-device CRUD validation",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.4",
        "name": "Fish Compatibility Checker Testing & Verification",
        "start": "2026-10-10", "end": "2026-11-09",
        "category": "Testing", "status": "Ongoing", "progress": 0.70,
        "evidence": "test/compatibility_rule_engine_test.dart (pairwise validation)",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.5",
        "name": "AquaBot Domain-Specific AI Response Testing",
        "start": "2026-10-16", "end": "2026-11-10",
        "category": "Testing", "status": "Ongoing", "progress": 0.60,
        "evidence": "backend/test_ai.py & query hallucination guard tests",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.6",
        "name": "Community Post, Like & Comment Testing",
        "start": "2026-10-20", "end": "2026-11-08",
        "category": "Testing", "status": "Ongoing", "progress": 0.50,
        "evidence": "Aggregate query comment count & like idempotency tests",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.7",
        "name": "Profile Avatar Display & Community Post Verification",
        "start": "2026-10-28", "end": "2026-11-11",
        "category": "Testing", "status": "Ongoing", "progress": 0.40,
        "evidence": "test/user_avatar_test.dart & stream listener deduplication check",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.8",
        "name": "Reminder Scheduling & Android Local Notification Testing",
        "start": "2026-10-12", "end": "2026-11-09",
        "category": "Testing", "status": "Ongoing", "progress": 0.75,
        "evidence": "Exact alarm trigger testing, overdue status calculation tests",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.9",
        "name": "UI Responsiveness, Layout & Overflow Testing",
        "start": "2026-10-24", "end": "2026-11-10",
        "category": "Testing", "status": "Ongoing", "progress": 0.70,
        "evidence": "Multi-screen resolution testing, RenderFlex overflow fixes in reminder.dart",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.10",
        "name": "Integration Testing Across All Application Modules",
        "start": "2026-11-06", "end": "2026-11-14",
        "category": "Testing", "status": "Planned", "progress": 0.0,
        "evidence": "End-to-end integration test suite execution",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.11",
        "name": "Final System Testing & Performance Verification",
        "start": "2026-11-10", "end": "2026-11-16",
        "category": "Testing", "status": "Planned", "progress": 0.0,
        "evidence": "Stress testing database queries and cold start benchmarks",
        "milestone": False
    },
    {
        "phase": "Phase 5: Testing and Refinement",
        "code": "5.12",
        "name": "Bug Fixing, Error Handling & Final Refinements",
        "start": "2026-10-28", "end": "2026-11-13",
        "category": "Refinement", "status": "Ongoing", "progress": 0.65,
        "evidence": "Elimination of flutter analyze warnings, defensive fallbacks",
        "milestone": False
    },

    # ─── Phase 6: Documentation and Evaluation (Accurate Status) ─────────────
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "6.1",
        "name": "Weekly Progress Report Preparation",
        "start": "2026-09-10", "end": "2026-11-05",
        "category": "Documentation", "status": "Completed", "progress": 1.0,
        "evidence": "Continuous weekly supervisor submissions (Weeks 1 to 8)",
        "milestone": False
    },
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "6.2",
        "name": "Reflective Report Writing and Improvement",
        "start": "2026-10-14", "end": "2026-11-06",
        "category": "Documentation", "status": "Ongoing", "progress": 0.75,
        "evidence": "Mid-to-late stage reflection drafted alongside AI & testing",
        "milestone": False
    },
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "6.3",
        "name": "Evaluation of Development Progress, Risks & Challenges",
        "start": "2026-10-25", "end": "2026-11-07",
        "category": "Documentation", "status": "Ongoing", "progress": 0.60,
        "evidence": "Risk mitigation analysis & MoSCoW evaluation draft",
        "milestone": False
    },
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "6.4",
        "name": "Final Technical Report Preparation & Compilation",
        "start": "2026-10-24", "end": "2026-11-13",
        "category": "Documentation", "status": "Ongoing", "progress": 0.55,
        "evidence": "Documentation/final-report comprehensive thesis drafting",
        "milestone": False
    },
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "6.5",
        "name": "Reflective Report Comprehensive Review",
        "start": "2026-11-02", "end": "2026-11-10",
        "category": "Documentation", "status": "Ongoing", "progress": 0.40,
        "evidence": "Reflective report proofreading and supervisor feedback alignment",
        "milestone": False
    },
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "6.6",
        "name": "Final Project Demonstration Preparation",
        "start": "2026-11-08", "end": "2026-11-16",
        "category": "Demonstration", "status": "Planned", "progress": 0.0,
        "evidence": "Demo dataset seeding, slide deck & live demonstration script",
        "milestone": False
    },
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "M5",
        "name": "○ Target Milestone: Comprehensive Application Release & Freeze",
        "start": "2026-11-14", "end": "2026-11-14",
        "category": "Milestone", "status": "Planned", "progress": 0.0,
        "evidence": "Target completion of all module integration tests and final build",
        "milestone": True
    },
    {
        "phase": "Phase 6: Documentation and Evaluation",
        "code": "M6",
        "name": "○ Target Milestone: University Final Project Submission",
        "start": "2026-11-18", "end": "2026-11-18",
        "category": "Milestone", "status": "Planned", "progress": 0.0,
        "evidence": "Final thesis submission and demonstration (Date pending confirmation)",
        "milestone": True
    }
]

# Action Plan Remaining Tasks
ACTION_PLAN = [
    {
        "id": "AP-01",
        "task": "Verify Fish Compatibility Database Records",
        "scope": "Verify Firestore compatibility documents and ensure species parameter pairs (pH, temperature, temperament) are complete and accurate.",
        "priority": "High",
        "status": "In Progress",
        "target_date": "2026-11-09"
    },
    {
        "id": "AP-02",
        "task": "Complete AquaBot Domain AI Response Testing",
        "scope": "Execute backend/test_ai.py test harness, evaluate domain guardrails against off-topic queries, and tune system prompt restrictions.",
        "priority": "High",
        "status": "In Progress",
        "target_date": "2026-11-10"
    },
    {
        "id": "AP-03",
        "task": "Test Firebase Integration & Security Rules Permissions",
        "scope": "Publish and verify split user rules (public profile read vs private subcollections) in Firebase Emulator and Production.",
        "priority": "High",
        "status": "In Progress",
        "target_date": "2026-11-08"
    },
    {
        "id": "AP-04",
        "task": "Verify Community Features & Avatar Display",
        "scope": "Validate AuthorAvatar widget caching, cross-user stream deduplication, and initials fallback across multiple physical devices.",
        "priority": "High",
        "status": "In Progress",
        "target_date": "2026-11-11"
    },
    {
        "id": "AP-05",
        "task": "Complete Reminder & Notification Testing",
        "scope": "Verify exact notification alarms on Android 12+ devices, permission dialog flows, background task waking, and overdue calculations.",
        "priority": "Medium",
        "status": "In Progress",
        "target_date": "2026-11-09"
    },
    {
        "id": "AP-06",
        "task": "Conduct Full Application Integration Testing",
        "scope": "Execute end-to-end user workflows: Login -> Add Aquarium -> Schedule Reminder -> Run Compatibility Check -> Ask AquaBot -> Post to Community.",
        "priority": "High",
        "status": "Planned",
        "target_date": "2026-11-14"
    },
    {
        "id": "AP-07",
        "task": "Fix Remaining UI & Functional Bugs",
        "scope": "Resolve any remaining RenderFlex overflow risks on ultra-small screens, ensure dark theme palette consistency across all modals.",
        "priority": "Medium",
        "status": "In Progress",
        "target_date": "2026-11-12"
    },
    {
        "id": "AP-08",
        "task": "Update Technical Documentation & Testing Evidence",
        "scope": "Capture screenshots of test results, update Database_Schema.md and API documentation with finalized endpoints and data structures.",
        "priority": "Medium",
        "status": "Planned",
        "target_date": "2026-11-13"
    },
    {
        "id": "AP-09",
        "task": "Review and Finalise Reflective and Final Reports",
        "scope": "Incorporate supervisor review feedback, complete critical evaluation of engineering challenges, proofread final dissertation chapters.",
        "priority": "High",
        "status": "In Progress",
        "target_date": "2026-11-15"
    },
    {
        "id": "AP-10",
        "task": "Prepare Final Project Demonstration",
        "scope": "Curate realistic sample aquarium datasets, prepare demo script, rehearse live mobile walkthrough and AI interaction for viva.",
        "priority": "High",
        "status": "Planned",
        "target_date": "2026-11-16"
    },
    {
        "id": "AP-11",
        "task": "Complete University Project Submission When Ready",
        "scope": "Submit final report, source code archive, demonstration video, and documentation package to university portal once approved.",
        "priority": "Critical",
        "status": "Planned",
        "target_date": "Pending Confirmation"
    }
]


def generate_excel():
    wb = openpyxl.Workbook()
    
    # ─── Sheet 1: Project Schedule & Gantt Data ──────────────────────────────
    ws1 = wb.active
    ws1.title = "Project Schedule"
    ws1.views.sheetView[0].showGridLines = True
    
    # Style definitions
    header_fill = PatternFill(start_color="0F172A", end_color="0F172A", fill_type="solid")
    header_font = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
    phase_fill = PatternFill(start_color="F1F5F9", end_color="F1F5F9", fill_type="solid")
    phase_font = Font(name="Calibri", size=11, bold=True, color="0F172A")
    regular_font = Font(name="Calibri", size=10)
    
    # Status Fills
    status_fills = {
        "Completed": PatternFill(start_color="DCFCE7", end_color="DCFCE7", fill_type="solid"),       # Soft Green
        "Ongoing": PatternFill(start_color="FFEDD5", end_color="FFEDD5", fill_type="solid"),         # Soft Orange
        "Planned": PatternFill(start_color="E0F2FE", end_color="E0F2FE", fill_type="solid"),         # Soft Blue
        "Post-Period Progress": PatternFill(start_color="F1F5F9", end_color="F1F5F9", fill_type="solid") # Soft Slate
    }
    status_fonts = {
        "Completed": Font(name="Calibri", size=10, bold=True, color="166534"),
        "Ongoing": Font(name="Calibri", size=10, bold=True, color="9A3412"),
        "Planned": Font(name="Calibri", size=10, bold=True, color="0369A1"),
        "Post-Period Progress": Font(name="Calibri", size=10, bold=True, color="475569")
    }
    
    thin_border = Border(
        left=Side(style='thin', color='CBD5E1'),
        right=Side(style='thin', color='CBD5E1'),
        top=Side(style='thin', color='CBD5E1'),
        bottom=Side(style='thin', color='CBD5E1')
    )
    
    # Title Block
    ws1.merge_cells("A1:I1")
    ws1["A1"] = "AquaIntel: A Domain-Specific AI System for Smart Aquarium Management"
    ws1["A1"].font = Font(name="Calibri", size=16, bold=True, color="0F172A")
    ws1["A1"].alignment = Alignment(horizontal="left", vertical="center")
    
    ws1.merge_cells("A2:I2")
    ws1["A2"] = "Master Development Schedule & Action Plan Status | Baseline: 10 Sep – 05 Nov 2026 | Extended Work: 09 Nov 2026"
    ws1["A2"].font = Font(name="Calibri", size=11, italic=True, color="475569")
    ws1["A2"].alignment = Alignment(horizontal="left", vertical="center")
    
    headers = [
        "WBS", "Task / Activity Name", "Phase", "Category", 
        "Start Date", "End Date", "Duration (Days)", "Status", 
        "Primary Verification Evidence / Scope"
    ]
    
    ws1.row_dimensions[4].height = 26
    for col_idx, h in enumerate(headers, 1):
        cell = ws1.cell(row=4, column=col_idx, value=h)
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="center" if col_idx in [1, 4, 5, 6, 7, 8] else "left", vertical="center")
        cell.border = thin_border
        
    current_row = 5
    current_phase = ""
    
    for task in TASKS:
        if task["phase"] != current_phase:
            current_phase = task["phase"]
            ws1.merge_cells(start_row=current_row, start_column=1, end_row=current_row, end_column=9)
            phase_cell = ws1.cell(row=current_row, column=1, value=f"■ {current_phase.upper()}")
            phase_cell.fill = phase_fill
            phase_cell.font = phase_font
            phase_cell.alignment = Alignment(horizontal="left", vertical="center", indent=1)
            for c in range(1, 10):
                ws1.cell(row=current_row, column=c).border = thin_border
            ws1.row_dimensions[current_row].height = 22
            current_row += 1
            
        s_date = datetime.date.fromisoformat(task["start"])
        e_date = datetime.date.fromisoformat(task["end"])
        duration = (e_date - s_date).days + 1
        
        ws1.row_dimensions[current_row].height = 20
        
        c1 = ws1.cell(row=current_row, column=1, value=task["code"])
        c1.alignment = Alignment(horizontal="center", vertical="center")
        
        c2 = ws1.cell(row=current_row, column=2, value=task["name"])
        c2.alignment = Alignment(horizontal="left", vertical="center")
        
        c3 = ws1.cell(row=current_row, column=3, value=task["phase"].split(":")[1].strip())
        c3.alignment = Alignment(horizontal="left", vertical="center")
        
        c4 = ws1.cell(row=current_row, column=4, value=task["category"])
        c4.alignment = Alignment(horizontal="center", vertical="center")
        
        c5 = ws1.cell(row=current_row, column=5, value=task["start"])
        c5.alignment = Alignment(horizontal="center", vertical="center")
        
        c6 = ws1.cell(row=current_row, column=6, value=task["end"])
        c6.alignment = Alignment(horizontal="center", vertical="center")
        
        c7 = ws1.cell(row=current_row, column=7, value=duration)
        c7.alignment = Alignment(horizontal="center", vertical="center")
        
        c8 = ws1.cell(row=current_row, column=8, value=task["status"])
        c8.alignment = Alignment(horizontal="center", vertical="center")
        c8.fill = status_fills.get(task["status"], PatternFill(fill_type=None))
        c8.font = status_fonts.get(task["status"], regular_font)
        
        c9 = ws1.cell(row=current_row, column=9, value=task["evidence"])
        c9.alignment = Alignment(horizontal="left", vertical="center")
        
        for c in [c1, c2, c3, c4, c5, c6, c7, c9]:
            c.font = regular_font
            c.border = thin_border
            if task["milestone"]:
                c.font = Font(name="Calibri", size=10, bold=True, color="0F172A")
                c.fill = PatternFill(start_color="FEF2F2", end_color="FEF2F2", fill_type="solid")
                
        c8.border = thin_border
        current_row += 1

    col_widths = {1: 8, 2: 58, 3: 26, 4: 16, 5: 14, 6: 14, 7: 15, 8: 22, 9: 72}
    for col_idx, width in col_widths.items():
        ws1.column_dimensions[get_column_letter(col_idx)].width = width

    # ─── Sheet 2: Action Plan Log (Remaining Work) ───────────────────────────
    ws2 = wb.create_sheet(title="Action Plan (Remaining Work)")
    ws2.views.sheetView[0].showGridLines = True
    
    ws2.merge_cells("A1:E1")
    ws2["A1"] = "AquaIntel Project – Action Plan Log (Outstanding Tasks & Finalization)"
    ws2["A1"].font = Font(name="Calibri", size=15, bold=True, color="0F172A")
    
    ap_headers = ["Action ID", "Remaining Task / Deliverable", "Scope of Work & Protocol", "Priority", "Status", "Target Date"]
    ws2.row_dimensions[3].height = 25
    for col_idx, h in enumerate(ap_headers, 1):
        cell = ws2.cell(row=3, column=col_idx, value=h)
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="center" if col_idx in [1, 4, 5, 6] else "left", vertical="center")
        cell.border = thin_border
        
    ap_row = 4
    for item in ACTION_PLAN:
        ws2.row_dimensions[ap_row].height = 22
        ws2.cell(row=ap_row, column=1, value=item["id"]).alignment = Alignment(horizontal="center", vertical="center")
        ws2.cell(row=ap_row, column=2, value=item["task"]).alignment = Alignment(horizontal="left", vertical="center")
        ws2.cell(row=ap_row, column=3, value=item["scope"]).alignment = Alignment(horizontal="left", vertical="center")
        ws2.cell(row=ap_row, column=4, value=item["priority"]).alignment = Alignment(horizontal="center", vertical="center")
        
        status_cell = ws2.cell(row=ap_row, column=5, value=item["status"])
        status_cell.alignment = Alignment(horizontal="center", vertical="center")
        if item["status"] == "In Progress":
            status_cell.fill = status_fills["Ongoing"]
            status_cell.font = status_fonts["Ongoing"]
        else:
            status_cell.fill = status_fills["Planned"]
            status_cell.font = status_fonts["Planned"]
            
        ws2.cell(row=ap_row, column=6, value=item["target_date"]).alignment = Alignment(horizontal="center", vertical="center")
        
        for c in range(1, 7):
            if c != 5:
                ws2.cell(row=ap_row, column=c).font = regular_font
            ws2.cell(row=ap_row, column=c).border = thin_border
        ap_row += 1
        
    ap_col_widths = {1: 12, 2: 44, 3: 75, 4: 14, 5: 16, 6: 22}
    for col_idx, width in ap_col_widths.items():
        ws2.column_dimensions[get_column_letter(col_idx)].width = width

    # ─── Sheet 3: Key Milestones (Achieved vs Target) ─────────────────────────
    ws3 = wb.create_sheet(title="Milestones")
    ws3.views.sheetView[0].showGridLines = True
    
    ws3.merge_cells("A1:F1")
    ws3["A1"] = "AquaIntel Project – Project Milestones Register"
    ws3["A1"].font = Font(name="Calibri", size=15, bold=True, color="0F172A")
    
    m_headers = ["Milestone ID", "Milestone Title", "Date / Target", "Phase", "Verification Evidence", "Status"]
    ws3.row_dimensions[3].height = 24
    for col_idx, h in enumerate(m_headers, 1):
        cell = ws3.cell(row=3, column=col_idx, value=h)
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal="center" if col_idx in [1, 3, 6] else "left", vertical="center")
        cell.border = thin_border
        
    m_row = 4
    for task in TASKS:
        if task["milestone"]:
            ws3.row_dimensions[m_row].height = 22
            ws3.cell(row=m_row, column=1, value=task["code"]).alignment = Alignment(horizontal="center")
            ws3.cell(row=m_row, column=2, value=task["name"].replace("★ ", "").replace("○ ", "")).alignment = Alignment(horizontal="left")
            ws3.cell(row=m_row, column=3, value=task["start"]).alignment = Alignment(horizontal="center")
            ws3.cell(row=m_row, column=4, value=task["phase"].split(":")[1].strip()).alignment = Alignment(horizontal="left")
            ws3.cell(row=m_row, column=5, value=task["evidence"]).alignment = Alignment(horizontal="left")
            
            sc = ws3.cell(row=m_row, column=6, value=task["status"])
            sc.alignment = Alignment(horizontal="center")
            sc.fill = status_fills.get(task["status"], PatternFill(fill_type=None))
            sc.font = status_fonts.get(task["status"], regular_font)
            
            for c in range(1, 7):
                if c != 6:
                    ws3.cell(row=m_row, column=c).font = regular_font
                ws3.cell(row=m_row, column=c).border = thin_border
            m_row += 1
            
    m_col_widths = {1: 15, 2: 50, 3: 16, 4: 28, 5: 65, 6: 18}
    for col_idx, width in m_col_widths.items():
        ws3.column_dimensions[get_column_letter(col_idx)].width = width

    excel_path = os.path.join("Documentation", "AquaIntel_Project_Schedule.xlsx")
    wb.save(excel_path)
    print(f"Generated Excel: {excel_path}")


def generate_gantt_chart():
    # Dimensions: 26 x 16.5 inches at 300 DPI (Generous height for 38 distinct rows)
    fig, ax = plt.subplots(figsize=(26, 17), dpi=300)
    fig.patch.set_facecolor('#FFFFFF')
    ax.set_facecolor('#FAFAFA')

    # Color palette strictly following user instructions:
    # Green = Completed, Orange = Ongoing, Blue/Grey = Planned
    status_colors = {
        "Completed": "#16A34A",           # Green
        "Ongoing": "#EA580C",             # Orange
        "Planned": "#3B82F6",             # Blue
        "Post-Period Progress": "#64748B" # Slate Grey with Pattern
    }

    plot_items = list(reversed(TASKS))
    y_positions = range(len(plot_items))
    y_labels = []

    proj_start = datetime.date(2026, 9, 8)
    proj_end = datetime.date(2026, 11, 20)
    dev_period_end = datetime.date(2026, 11, 5)

    # Phase shading
    phase_colors = {
        "Phase 1": "#F8FAFC",
        "Phase 2": "#FFFFFF",
        "Phase 3": "#F8FAFC",
        "Phase 4": "#FFFFFF",
        "Phase 5": "#F8FAFC",
        "Phase 6": "#FFFFFF",
    }
    
    for i, item in enumerate(plot_items):
        p_key = item["phase"].split(":")[0]
        bg_col = phase_colors.get(p_key, "#FFFFFF")
        ax.axhspan(i - 0.48, i + 0.48, color=bg_col, zorder=0, alpha=0.9)

        s_date = datetime.date.fromisoformat(item["start"])
        e_date = datetime.date.fromisoformat(item["end"])
        dur = (e_date - s_date).days + 1
        
        # Plotting
        if item["milestone"]:
            if item["status"] == "Completed":
                ax.scatter(s_date, i, color=status_colors["Completed"], s=150, marker='D', zorder=5, edgecolor='#14532D', linewidth=1.8)
                label_text = f"★ {item['name'].replace('★ Milestone: ', '')} ({s_date.strftime('%d %b')}) [Achieved]"
                text_col = '#166534'
                ax.text(s_date + datetime.timedelta(days=0.8), i, label_text, va='center', ha='left',
                        fontsize=8.5, fontweight='bold', color=text_col, zorder=6)
            else:
                ax.scatter(s_date, i, color='#FFFFFF', s=150, marker='D', zorder=5, edgecolor='#0284C7', linewidth=2.2)
                label_text = f"○ {item['name'].replace('○ Target Milestone: ', '')} [Target / Pending]"
                text_col = '#0369A1'
                # Position text to the left of the hollow diamond so it stays comfortably inside the chart area
                ax.text(s_date - datetime.timedelta(days=0.8), i, label_text, va='center', ha='right',
                        fontsize=8.5, fontweight='bold', color=text_col, zorder=6)
        else:
            bar_color = status_colors[item["status"]]
            hatch = None
            if item["status"] == "Post-Period Progress":
                hatch = '...'
            elif item["status"] == "Ongoing":
                hatch = '//'

            # Draw bar
            ax.barh(i, dur, left=s_date, height=0.56, align='center', color=bar_color, 
                    edgecolor='#0F172A', linewidth=0.6, alpha=0.90, hatch=hatch, zorder=3)
            
            # Badge text next to bar
            extra_text = f"{dur}d • {item['status']}"
            if item["name"] == "Reflective Report Writing and Improvement":
                extra_text += " [Mid/Late Stage Reflection]"
            elif item["status"] == "Post-Period Progress":
                extra_text += " [Commit 4acf4f7]"

            text_color = "#0F172A"
            ax.text(e_date + datetime.timedelta(days=0.5), i, extra_text, va='center', ha='left',
                    fontsize=7.8, color=text_color, fontweight='bold', zorder=4)

        # Full task name on Y-axis
        clean_name = item["name"].replace("★ Milestone: ", "M: ").replace("○ Target Milestone: ", "M: ")
        y_labels.append(f"{item['code']} {clean_name}")

    ax.set_yticks(y_positions)
    ax.set_yticklabels(y_labels, fontsize=8.8, fontweight='medium', color='#0F172A')

    # Dates
    ax.set_xlim(proj_start, proj_end)
    ax.xaxis.set_major_locator(mdates.WeekdayLocator(byweekday=mdates.MO, interval=1))
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%d %b\n(Week %W)'))
    ax.xaxis.set_minor_locator(mdates.DayLocator(interval=1))

    # Top X-axis
    sec_ax = ax.secondary_xaxis('top')
    sec_ax.xaxis.set_major_locator(mdates.WeekdayLocator(byweekday=mdates.MO, interval=1))
    sec_ax.xaxis.set_major_formatter(mdates.DateFormatter('%d %b %Y'))
    sec_ax.tick_params(labelsize=8.5, colors='#334155')

    # Gridlines
    ax.grid(True, which='major', axis='x', color='#CBD5E1', linestyle='-', linewidth=0.8, alpha=0.8)
    ax.grid(True, which='minor', axis='x', color='#E2E8F0', linestyle=':', linewidth=0.5, alpha=0.5)
    ax.grid(True, which='major', axis='y', color='#E2E8F0', linestyle='-', linewidth=0.5, alpha=0.7)

    # Historical Development Period Cutoff Line (05 Nov)
    ax.axvline(dev_period_end, color='#B91C1C', linestyle='--', linewidth=2.0, zorder=7)
    ax.text(dev_period_end - datetime.timedelta(days=0.3), len(plot_items) - 0.2, 
            'HISTORICAL DEV PERIOD END\n05 November 2026', 
            color='#991B1B', fontsize=8.8, fontweight='bold', ha='right', va='top', zorder=8,
            bbox=dict(boxstyle='square,pad=0.3', facecolor='#FEF2F2', edgecolor='#DC2626', linewidth=1.0, alpha=0.95))

    # Extended Iteration Shading (Post 05 Nov)
    ax.axvspan(dev_period_end, proj_end, color='#F8FAFC', alpha=0.6, zorder=1)
    ax.text(datetime.date(2026, 11, 12), len(plot_items) - 8, 
            'Post-Period Extended Work\n& Ongoing Evaluation Cycle\n(Commit 4acf4f7 | 09 Nov)',
            color='#334155', fontsize=8.5, fontstyle='italic', ha='center', va='center', zorder=3,
            bbox=dict(boxstyle='round,pad=0.35', facecolor='#FFFFFF', edgecolor='#94A3B8', alpha=0.95))

    # Title
    plt.title("AquaIntel: A Domain-Specific AI System for Smart Aquarium Management\n"
              "Development Timeline, Current Project Status & Action Plan Tracking (10 Sep 2026 – Present)",
              fontsize=15, fontweight='bold', color='#0F172A', pad=32)

    # Custom Legend explicitly following user instructions
    legend_patches = [
        mpatches.Patch(facecolor=status_colors["Completed"], edgecolor='#0F172A', label='Completed Activity (Verified via Commit / Artifact)'),
        mpatches.Patch(facecolor=status_colors["Ongoing"], hatch='//', edgecolor='#0F172A', label='Ongoing Activity (Active In-Progress / Incremental Testing)'),
        mpatches.Patch(facecolor=status_colors["Planned"], edgecolor='#0F172A', label='Planned Activity (Pending Execution in Action Plan)'),
        Line2D([0], [0], marker='D', color='w', markerfacecolor=status_colors["Completed"], markersize=9, markeredgecolor='#14532D', label='Achieved Milestone'),
        Line2D([0], [0], marker='D', color='w', markerfacecolor='#FFFFFF', markersize=9, markeredgecolor='#0284C7', label='Target / Pending Milestone'),
        mpatches.Patch(facecolor=status_colors["Post-Period Progress"], hatch='...', edgecolor='#0F172A', label='Post-Period Progress (09 Nov Commit: Avatar & Refinements)')
    ]
    ax.legend(handles=legend_patches, loc='lower right', bbox_to_anchor=(1.0, -0.090),
              ncol=3, fontsize=9.0, frameon=True, facecolor='#FFFFFF', edgecolor='#CBD5E1')

    # Footnote
    plt.figtext(0.27, 0.012,
                "Note: The project is currently active and has NOT been submitted. Testing and report preparation activities are ongoing. "
                "Baseline development period concluded on 05 Nov 2026; post-period progress (09 Nov Commit 4acf4f7) and remaining action plan tasks are represented accurately.",
                fontsize=8.2, color='#475569', fontstyle='italic')

    plt.subplots_adjust(left=0.28, right=0.97, top=0.91, bottom=0.09)

    # Save PNG
    png_path = os.path.join("Documentation", "AquaIntel_Gantt_Chart.png")
    plt.savefig(png_path, dpi=300, facecolor=fig.get_facecolor(), edgecolor='none')
    print(f"Generated PNG: {png_path}")

    # Generate A4 Landscape PDF using ReportLab
    pdf_path = os.path.join("Documentation", "AquaIntel_Gantt_Chart.pdf")
    c = canvas.Canvas(pdf_path, pagesize=landscape(A4))
    width, height = landscape(A4)
    margin = 10
    c.drawImage(png_path, margin, margin, width=width - 2*margin, height=height - 2*margin, preserveAspectRatio=True, anchor='c')
    c.showPage()
    c.save()
    print(f"Generated A4 Landscape PDF: {pdf_path}")
    plt.close()


def generate_action_plan_markdown():
    doc_path = os.path.join("Documentation", "AquaIntel_Action_Plan.md")
    content = """# AquaIntel – Final-Year Project Action Plan & Remaining Work

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
"""
    with open(doc_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated Action Plan Markdown: {doc_path}")


if __name__ == "__main__":
    generate_excel()
    generate_gantt_chart()
    generate_action_plan_markdown()
