# AquaIntel – Smart Aquarium Management System

## 1. Project Overview

**AquaIntel** is a mobile-based smart aquarium management application developed as a final-year software engineering project.

### Official Project Title

> **AquaIntel: A Domain-Specific AI System for Smart Aquarium Management**

### Short Description

AquaIntel is a Flutter mobile application designed to help aquarium owners manage their aquariums, monitor important tank information, receive maintenance reminders, check fish compatibility, calculate tank volume, and interact with a domain-specific AI assistant called **AquaBot**.

The application focuses specifically on aquarium management rather than acting as a general-purpose AI or generic lifestyle application.

---

## 2. Main Objectives

The main objectives of AquaIntel are:

1. Provide a simple mobile interface for managing aquarium information.
2. Allow users to create and manage aquarium profiles.
3. Store aquarium information securely in a cloud database.
4. Provide aquarium maintenance reminders.
5. Help users understand fish compatibility.
6. Provide aquarium-related calculations such as tank volume.
7. Provide a domain-specific AI chatbot for aquarium questions.
8. Display useful aquarium health information.
9. Maintain historical aquarium information and logs.
10. Provide a scalable foundation for future aquarium-related community and recommendation features.

---

# 3. Target Users

AquaIntel is designed for:

- Beginner aquarium owners
- Intermediate aquarium keepers
- Fish hobbyists
- Users maintaining multiple aquariums
- Users who need reminders for aquarium maintenance
- Users who need help selecting compatible fish
- Users who want quick aquarium-related information

The application is intended to make aquarium management easier for users who may not have extensive technical knowledge about fish keeping.

---

# 4. Technology Stack

## Frontend

- **Flutter**
- **Dart**
- Material 3
- Responsive mobile UI

## Authentication

- **Firebase Authentication**
- Email/password authentication

## Database

- **Cloud Firestore**

Firestore is used to store application data such as:

- User profiles
- Aquarium information
- Aquarium settings
- Fish information
- Reminders
- Maintenance records
- Compatibility data
- Future community posts

## AI / Backend

AquaIntel uses a backend/API approach for AI-related functionality.

Possible backend technologies include:

- Python
- FastAPI
- AI/LLM integration
- Domain-specific prompt restrictions
- Retrieval/database-backed aquarium knowledge

## Development Tools

- Android Studio
- Visual Studio Code
- Flutter SDK
- Firebase Console
- Git
- GitHub

## Repository

GitHub repository:

`https://github.com/amogh19skya/AquaIntel.git`

---

# 5. Application Architecture

AquaIntel follows a layered mobile application architecture.

```text
                         AquaIntel
                            |
            +---------------+---------------+
            |                               |
       Flutter App                    Backend / AI
            |                               |
    +-------+-------+                       |
    |               |                       |
   UI          Application Logic        AquaBot API
    |               |                       |
    +-------+-------+                       |
            |                               |
       Firebase Services                    |
            |                               |
    +-------+-------+                       |
    |               |                       |
 Firebase Auth   Firestore                  |
    |               |                       |
    +---------------+-----------------------+
                    |
               AquaIntel Data
```

---

# 6. Authentication

AquaIntel uses Firebase Authentication for account management.

## Current Authentication Method

The application uses:

- Email registration
- Email login
- Password authentication
- Firebase user sessions
- Logout functionality
- Display name support

Google and Apple authentication are not currently part of the planned authentication interface.

## Authentication Flow

```text
User opens application
        |
        v
   Splash Screen
        |
        v
Is user authenticated?
      /   \
    Yes    No
     |      |
     v      v
   Home   Sign In
             |
             v
        Register / Login
             |
             v
      Firebase Authentication
             |
             v
           Home
```

---

# 7. Firebase Configuration

The Firebase project is:

```text
aquaintel-36924
```

The Flutter Android application uses:

```text
com.example.aquaintel
```

Firebase configuration is generated through FlutterFire.

The project contains:

```text
lib/firebase_options.dart
```

Firebase initialization is performed when the application starts.

---

# 8. Firestore Database

Cloud Firestore is used as the main application database.

The purpose of Firestore is to allow user-specific aquarium information to be stored and retrieved from the cloud.

A simplified database structure is:

```text
users
 |
 +-- {userId}
       |
       +-- profile information
       |
       +-- aquariums
       |      |
       |      +-- {aquariumId}
       |             |
       |             +-- aquarium details
       |             +-- fish
       |             +-- maintenance
       |             +-- water parameters
       |             +-- history
       |
       +-- reminders
              |
              +-- {reminderId}
```

---

# 9. User Data

A user profile may contain:

```text
users/{userId}

- displayName
- email
- profileImage
- createdAt
- updatedAt
```

The Firebase Authentication user remains responsible for authentication credentials.

Firestore stores additional application/profile information.

---

# 10. Aquarium Data

Each user can have one or more aquarium records.

Example:

```text
users/{userId}/aquariums/{aquariumId}
```

Possible fields include:

```text
name
type
volume
shape
length
width
height
temperature
location
ph
createdAt
updatedAt
```

Example aquarium:

```text
Name: Aqua Aura
Type: Freshwater
Volume: 5000 L
Shape: Rectangular
Temperature: 36°C
Location: Living Room
```

The exact production schema can be expanded as development continues.

---

# 11. Main Application Features

AquaIntel is designed around the following major features:

1. User Authentication
2. Aquarium Management
3. Dashboard
4. Aquarium Compatibility Checker
5. Tank Volume Calculator
6. Maintenance Reminders
7. Water Parameter Tracking
8. AquaBot AI Assistant
9. Aquarium History
10. Settings and Profile Management
11. Future Community Aquarium Posts

---

# 12. Dashboard / Home Screen

The home screen acts as the central dashboard.

The dashboard can display:

- Current aquarium
- Aquarium name
- Aquarium type
- Tank volume
- Temperature
- Location
- Aquarium health information
- Compatibility Checker
- Tank Volume Calculator
- Navigation controls

The application uses a bottom navigation structure.

Current navigation concept:

```text
Maintenance | Dashboard | Library | Settings
```

A central action button can also be used for important aquarium actions.

---

# 13. Aquarium Management

Users should be able to create and manage aquarium profiles.

## Add Aquarium

The Add Aquarium form can collect:

- Aquarium name
- Aquarium type
- Tank shape
- Length
- Width
- Height
- Volume
- Temperature
- pH
- Location
- Other aquarium information

After submission:

```text
Add Aquarium Form
        |
        v
Validate Input
        |
        v
Calculate / Confirm Volume
        |
        v
Save to Firestore
        |
        v
Refresh Dashboard
```

This allows the aquarium information to become persistent rather than being hard-coded into the UI.

---

# 14. Multi-Aquarium Support

A future-ready design allows a user to own multiple aquariums.

Example:

```text
User
 |
 +-- Aqua Aura
 |
 +-- Tropical Paradise
 |
 +-- Community Tank
 |
 +-- Betta Tank
```

Each aquarium should have its own:

- Fish
- Compatibility information
- Maintenance records
- Reminders
- Water parameters
- History

This prevents different aquariums from sharing incorrect information.

---

# 15. Tank Volume Calculator

The Tank Volume Calculator helps users determine the approximate volume of their aquarium.

For a rectangular tank:

```text
Volume = Length × Width × Height
```

The application can convert the result into litres depending on the units entered.

For example:

```text
Length = 100 cm
Width  = 50 cm
Height = 40 cm

Volume = 100 × 50 × 40
       = 200,000 cm³

Approximate volume = 200 L
```

The calculator can later support additional tank shapes.

Possible shapes:

- Rectangular
- Cuboid
- Cylindrical
- Custom

---

# 16. Fish Compatibility Checker

The Compatibility Checker is one of the important aquarium features.

## Current Version

The current implementation starts with a UI/rule-based approach.

The user selects or enters fish information and the system evaluates compatibility using defined rules.

Example:

```text
Fish A: Guppy
Fish B: Neon Tetra

Compatibility:
Compatible
```

The system can consider:

- Freshwater / saltwater environment
- Temperature range
- pH range
- Aggression
- Adult size
- Tank requirements
- Schooling requirements
- Habitat requirements
- Water conditions

---

# 17. Database-Driven Compatibility System

The rule-based compatibility system can be expanded using Firestore.

Instead of hard-coding every fish directly into Dart code, fish information can be stored in Firestore.

Example:

```text
fish
 |
 +-- guppy
 |     +-- name
 |     +-- waterType
 |     +-- minTemperature
 |     +-- maxTemperature
 |     +-- minPH
 |     +-- maxPH
 |     +-- aggression
 |     +-- minimumTankSize
 |
 +-- neon_tetra
 |
 +-- betta
 |
 +-- angelfish
```

A compatibility collection can also be created:

```text
compatibility
 |
 +-- guppy_neon_tetra
 +-- guppy_betta
 +-- neon_tetra_angelfish
```

The system can then calculate compatibility dynamically.

---

# 18. Compatibility Logic

A possible compatibility evaluation model is:

```text
                Fish Selection
                      |
                      v
             Retrieve Fish Data
                      |
                      v
              Compare Conditions
                      |
        +-------------+-------------+
        |             |             |
    Temperature      pH        Aggression
        |             |             |
        +-------------+-------------+
                      |
                      v
              Compatibility Score
                      |
                      v
             Recommendation
```

Example result:

```text
Compatibility: 82%

Suitable

Reasons:
✓ Similar temperature requirements
✓ Compatible pH range
✓ Similar water type
✓ Low aggression conflict

Considerations:
! Requires adequate swimming space
```

This approach makes the feature more scalable than maintaining a large number of hard-coded conditions.

---

# 19. Aquarium Water Parameters

AquaIntel can track important water parameters such as:

- pH
- Temperature
- Water condition
- Water-change history

The application can later support:

- Ammonia
- Nitrite
- Nitrate
- Hardness
- Salinity

The system can compare recorded values with recommended ranges for specific aquarium types or fish.

---

# 20. Aquarium Health Indicators

The dashboard can provide simple aquarium health indicators.

Example:

```text
Aquarium Health
----------------
Temperature   ✓ Good
pH            ✓ Good
Maintenance   ✓ Up to date
Water Change  ⚠ Due soon
```

A more advanced version can calculate an overall health score.

Example:

```text
Aquarium Health
      87%
     Healthy
```

The score should be presented as an informative indicator rather than a medical or scientific diagnosis.

---

# 21. Reminder and Maintenance System

AquaIntel provides reminders for aquarium maintenance.

Possible reminder types:

- Fish feeding
- Water change
- Filter cleaning
- Tank cleaning
- Water parameter checks
- Equipment maintenance

Example:

```text
Reminder
----------------
Water Change
Due: Tomorrow

Every: 7 days
```

---

# 22. Reminder Workflow

```text
User creates reminder
        |
        v
Validate reminder
        |
        v
Save reminder
        |
        v
Schedule / display reminder
        |
        v
User receives reminder
        |
        v
User marks task complete
        |
        v
Maintenance history updated
```

The reminder service should keep user-specific reminders separated using the authenticated user's ID.

---

# 23. Maintenance History

Maintenance activities can be stored for future reference.

Example:

```text
Maintenance History

01 Oct
Water Change
40%

28 Sep
Filter Cleaning
Completed

24 Sep
Water Parameter Check
Completed
```

This allows users to understand how consistently their aquarium is being maintained.

---

# 24. AquaBot – Domain-Specific AI Assistant

AquaBot is the AI component of AquaIntel.

The purpose of AquaBot is to provide aquarium-related assistance.

Unlike a general chatbot, AquaBot should remain restricted to the aquarium domain.

---

# 25. AquaBot Supported Topics

AquaBot can answer questions about:

- Fish care
- Feeding
- Aquarium setup
- Water quality
- pH
- Temperature
- Fish compatibility
- Tank maintenance
- Fish diseases
- Disease prevention
- Aquarium plants
- Filtration
- Cycling
- Water changes
- General aquarium management

Example:

```text
User:
How often should I change aquarium water?

AquaBot:
For many established freshwater aquariums,
a partial water change is commonly performed
regularly, with the exact schedule depending on
tank conditions, stocking, filtration and water
quality.
```

---

# 26. AquaBot Domain Restriction

AquaBot should reject unrelated questions.

Example:

```text
User:
Write me a Python program.

AquaBot:
I am AquaBot, an aquarium-focused assistant.
I can help with aquarium and fish-related questions.
```

This keeps the AI aligned with the project scope.

---

# 27. AquaBot Architecture

```text
Flutter App
     |
     v
AquaBot Chat UI
     |
     v
Backend API
     |
     v
Domain Validation
     |
     v
Aquarium Knowledge / AI Model
     |
     v
Response Validation
     |
     v
Flutter App
```

A future implementation can use:

- Retrieval-Augmented Generation (RAG)
- Aquarium knowledge documents
- Fish database
- Firestore aquarium information
- LLM API

This can make AquaBot more accurate and project-specific.

---

# 28. AquaBot Personalised Responses

A future version can allow AquaBot to use the user's aquarium data.

For example:

```text
User aquarium:

Type: Freshwater
Volume: 200 L
Temperature: 26°C
pH: 7.1
Fish: Guppy + Neon Tetra
```

The user asks:

```text
Is my aquarium temperature suitable?
```

AquaBot can use the stored aquarium information to provide a more contextual response.

---

# 29. Settings

The Settings screen provides application and account management options.

Possible options include:

- Edit Profile
- Profile image
- Display name
- Email
- Notification settings
- Reminder settings
- Application preferences
- Logout

The logout process signs the user out through Firebase Authentication and returns them to the authentication flow.

---

# 30. Profile Management

Users can update profile information such as:

- Display name
- Profile image
- Account-related information

The profile image can later be stored using Firebase Storage while the image URL is stored in Firestore.

---

# 31. Library

The Library section can contain aquarium-related resources.

Potential resources include:

- Fish information
- Plant information
- Aquarium guides
- Maintenance guides
- Disease information
- Compatibility information

A future implementation can make this section database-driven.

---

# 32. Future Community Feature

A potential future feature is an aquarium community.

Instead of requiring users to create a completely separate post, an aquarium could be converted into a community post directly.

Example:

```text
My Aquarium
     |
     v
"Publish Aquarium"
     |
     v
Community Post
     |
     +-- Aquarium image
     +-- Aquarium name
     +-- Aquarium details
     +-- Fish
     +-- Description
     |
     +-- Likes
     +-- Comments
```

This creates a more natural relationship between aquarium management and community sharing.

---

# 33. Community Database Concept

A future Firestore structure could be:

```text
posts
 |
 +-- {postId}
       |
       +-- userId
       +-- aquariumId
       +-- title
       +-- description
       +-- image
       +-- createdAt
       +-- likes
```

Comments:

```text
posts/{postId}/comments/{commentId}
```

This allows posts to remain connected to the original aquarium.

---

# 34. Notifications

Notifications can be used for:

- Feeding reminders
- Water-change reminders
- Filter maintenance
- Scheduled aquarium checks

A future implementation can use local notifications or Firebase-based notification services depending on the final architecture.

---

# 35. UI Design

The AquaIntel interface uses a dark aquarium-inspired visual theme.

Primary design colours currently include:

```text
Background:
#0D2D47

Top:
#205779

Card:
#1C4667

Input:
#163B5A

Primary:
#29A8DF

Secondary Text:
#70A9CC

Scaffold Background:
#0A2236
```

The design is intended to provide:

- Modern aquarium aesthetic
- High contrast
- Clear navigation
- Simple forms
- Consistent cards
- Easy-to-read aquarium information

---

# 36. UI Design Principles

AquaIntel follows these principles:

### Simplicity

The user should be able to understand the main functions without technical knowledge.

### Consistency

Buttons, cards, colours, icons and spacing should remain consistent.

### Accessibility

Text should be readable and important actions should be clearly visible.

### Information Hierarchy

Important aquarium information should appear before secondary information.

### Mobile First

The application is designed primarily for mobile devices.

---

# 37. Suggested Flutter Project Structure

A scalable project structure can be:

```text
lib/
│
├── main.dart
├── firebase_options.dart
│
├── auth/
│   ├── sign_in.dart
│   ├── sign_up.dart
│   └── auth_service.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── reminder.dart
│   ├── setting.dart
│   ├── compatibility_checker.dart
│   └── edit_profile.dart
│
├── services/
│   ├── settings_service.dart
│   ├── aquarium_service.dart
│   ├── reminder_service.dart
│   ├── compatibility_service.dart
│   └── chatbot_service.dart
│
├── models/
│   ├── user_model.dart
│   ├── aquarium_model.dart
│   ├── fish_model.dart
│   └── reminder_model.dart
│
├── widgets/
│   └── aqua_bottom_nav.dart
│
├── routes/
│   └── app_routes.dart
│
└── utils/
```

The exact directory names may differ as development continues.

---

# 38. Data Flow

A typical aquarium creation flow is:

```text
User
 |
 v
Add Aquarium Screen
 |
 v
Form Validation
 |
 v
Aquarium Model
 |
 v
Aquarium Service
 |
 v
Cloud Firestore
 |
 v
Aquarium Saved
 |
 v
Dashboard Updated
```

---

# 39. Security

Firebase Authentication provides the identity of the current user.

Firestore Security Rules should ensure that users can only access their own private aquarium data.

Conceptually:

```text
Authenticated User
       |
       v
Firebase UID
       |
       v
Firestore user/{UID}
       |
       v
Only authorised user data
```

Security rules should be designed so that one user cannot read or modify another user's private aquarium records.

---

# 40. Error Handling

The application should handle common errors such as:

- Invalid login credentials
- Existing email during registration
- Weak passwords
- Empty form fields
- Invalid aquarium dimensions
- Firestore connection problems
- Failed reminder creation
- AI API failures
- Network errors

Users should receive clear messages rather than technical exceptions.

Example:

```text
Unable to save aquarium.
Please check your internet connection and try again.
```

---

# 41. Validation

Important validation includes:

### Authentication

- Valid email
- Required password
- Password confirmation
- Minimum password requirements

### Aquarium

- Aquarium name required
- Positive dimensions
- Valid volume
- Valid temperature
- Valid pH range

### Reminders

- Reminder title required
- Valid date/time
- Valid recurrence

### Compatibility

- Fish selection required
- Valid fish records
- Valid aquarium type

---

# 42. Testing Strategy

AquaIntel should use multiple levels of testing.

## Unit Testing

Test individual functions such as:

- Tank volume calculation
- Compatibility calculations
- Input validation
- Reminder calculations

Example:

```text
Given:
Length = 100 cm
Width = 50 cm
Height = 40 cm

Expected:
Volume = 200 L
```

## Widget Testing

Test:

- Login form
- Registration form
- Aquarium form
- Compatibility checker
- Dashboard cards
- Settings

## Integration Testing

Test:

```text
Login
  ->
Firebase
  ->
Dashboard
```

and:

```text
Add Aquarium
  ->
Firestore
  ->
Dashboard
```

## User Acceptance Testing

Real users can test:

- Registering
- Logging in
- Creating an aquarium
- Checking compatibility
- Creating reminders
- Using AquaBot
- Editing profile
- Logging out

---

# 43. Example Test Cases

| Test ID | Feature | Test | Expected Result |
|---|---|---|---|
| TC01 | Registration | Enter valid email/password | Account created |
| TC02 | Registration | Enter existing email | Error displayed |
| TC03 | Login | Valid credentials | User enters app |
| TC04 | Login | Invalid password | Login rejected |
| TC05 | Aquarium | Create valid aquarium | Saved to Firestore |
| TC06 | Aquarium | Empty aquarium name | Validation error |
| TC07 | Calculator | Enter valid dimensions | Correct volume |
| TC08 | Compatibility | Select compatible fish | Compatible result |
| TC09 | Reminder | Create reminder | Reminder saved |
| TC10 | Settings | Logout | User returned to sign-in |
| TC11 | AquaBot | Aquarium question | Aquarium response |
| TC12 | AquaBot | Unrelated question | Domain restriction response |

---

# 44. Current Development Status

The project has progressed through several major stages.

### Completed / Implemented Areas

- Flutter project setup
- Firebase project configuration
- Firebase Authentication
- Email registration
- Email login
- Logout
- Splash/authentication routing
- Dark aquarium UI
- Main dashboard structure
- Settings screen
- Profile editing structure
- Reminder functionality
- Compatibility Checker UI
- Rule-based compatibility concept
- Tank Volume Calculator concept/UI
- Firestore integration planning
- Backend/API foundation
- AquaBot architecture
- GitHub repository

### In Development / Expansion

- Fully database-driven aquarium management
- Expanded fish compatibility database
- Persistent aquarium records
- Advanced water parameter tracking
- Expanded AquaBot knowledge
- Improved notification handling
- Multi-aquarium support

### Future Features

- Community aquarium posts
- Likes and comments
- Aquarium sharing
- Advanced recommendation system
- More fish species
- More compatibility factors
- RAG-based AquaBot
- Personalised AI recommendations
- Advanced aquarium health scoring

---

# 45. Project Development Roadmap

## Phase 1 – Foundation

- Flutter project
- Firebase setup
- Authentication
- Basic UI

## Phase 2 – Core Aquarium Management

- Add aquarium
- Firestore database
- Aquarium details
- Dashboard
- Multiple aquarium support

## Phase 3 – Aquarium Tools

- Tank volume calculator
- Compatibility checker
- Fish database
- Water parameter tracking

## Phase 4 – Maintenance

- Feeding reminders
- Water-change reminders
- Filter maintenance
- Maintenance history

## Phase 5 – AI

- AquaBot API
- Domain restriction
- Aquarium knowledge
- Personalised responses
- RAG/database integration

## Phase 6 – Testing

- Unit testing
- Widget testing
- Integration testing
- UAT
- Bug fixing

## Phase 7 – Deployment

- Android release build
- Final documentation
- Demonstration
- Evaluation

---

# 46. Future Expansion

AquaIntel can be expanded into a more advanced aquarium management platform.

Possible future features include:

### AI Fish Recommendations

Recommend fish based on:

- Tank size
- Water type
- Existing fish
- Temperature
- pH
- User preferences

### Automated Aquarium Health Score

Combine:

```text
Temperature
+
pH
+
Maintenance
+
Stocking
+
Water Parameters
=
Aquarium Health Indicator
```

### Advanced Knowledge Base

A structured aquarium knowledge database could improve AquaBot.

### Community

Users could share aquarium setups and interact with other aquarium owners.

### Image-Based Aquarium Analysis

A future AI feature could analyse aquarium images to identify possible:

- Fish species
- Plants
- Algae
- Aquarium equipment

This would require additional research and validation before being used as a reliable diagnostic feature.

---

# 47. Important Project Scope Boundary

AquaIntel is a software-based aquarium management system.

The current project does **not** depend on physical IoT sensors or Arduino hardware.

The application can work using:

- User-entered aquarium data
- Database records
- Application calculations
- AI assistance
- Reminders
- Rule-based/database-based compatibility

Physical sensor integration can remain a future enhancement.

---

# 48. Advantages of AquaIntel

### Centralised Aquarium Management

Users can manage important aquarium information from one application.

### Personalised Information

Aquarium data can be connected to user-specific recommendations.

### Database-Driven

Firestore allows information to persist between sessions.

### AI Assistance

AquaBot provides quick aquarium-related support.

### Maintenance Support

Reminders can help users maintain regular aquarium routines.

### Expandable Architecture

The application can later support community, advanced AI, more species, and additional aquarium tools.

---

# 49. Limitations

Potential limitations of the current system include:

1. Compatibility accuracy depends on the quality of the fish database and rules.
2. User-entered water parameters may not always be accurate.
3. AI responses require appropriate knowledge sources and validation.
4. Internet connectivity may be required for cloud and AI features.
5. The current system does not directly read physical aquarium sensors.
6. Notification behaviour may depend on the final notification implementation and device permissions.
7. The initial fish database may contain a limited number of species.

---

# 50. Privacy Considerations

AquaIntel should protect:

- Email addresses
- User profiles
- Aquarium information
- Uploaded images
- Community activity

Firestore Security Rules should restrict private user information.

If community features are introduced, users should understand which aquarium information becomes publicly visible.

---

# 51. Git and Version Control

The project is maintained using Git and GitHub.

Repository:

```text
AquaIntel
```

Main branch:

```text
main
```

Recommended workflow:

```text
Create / modify feature
        |
        v
Test locally
        |
        v
flutter analyze
        |
        v
flutter test
        |
        v
git add .
        |
        v
git commit
        |
        v
git push
```

---

# 52. Development Commands

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

Check Flutter environment:

```bash
flutter doctor
```

Analyze code:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build Android APK:

```bash
flutter build apk
```

Run the FastAPI backend, when required:

```bash
uvicorn main:app --reload
```

The local development backend has previously used:

```text
http://127.0.0.1:8000
```

FastAPI documentation:

```text
http://127.0.0.1:8000/docs
```

---

# 53. Suggested Firestore Structure

A more complete future structure can be:

```text
users
│
└── {userId}
    │
    ├── profile
    │
    ├── aquariums
    │   └── {aquariumId}
    │       ├── details
    │       ├── fish
    │       ├── plants
    │       ├── waterParameters
    │       ├── maintenance
    │       └── history
    │
    └── reminders
        └── {reminderId}


fish
│
├── guppy
├── neon_tetra
├── betta
└── ...


compatibility
│
├── guppy_neon_tetra
├── guppy_betta
└── ...


posts
│
└── {postId}
    └── comments
        └── {commentId}
```

This structure can be adjusted according to the final application architecture.

---

# 54. Example User Journey

```text
1. User opens AquaIntel
             |
             v
2. Splash screen
             |
             v
3. Sign in / Sign up
             |
             v
4. Firebase authentication
             |
             v
5. Dashboard
             |
             v
6. Add Aquarium
             |
             v
7. Aquarium saved to Firestore
             |
             v
8. User views aquarium
             |
       +-----+-----+
       |           |
       v           v
Compatibility   Calculator
       |           |
       +-----+-----+
             |
             v
       Maintenance
             |
             v
        Reminders
             |
             v
          AquaBot
             |
             v
     Aquarium assistance
```

---

# 55. Academic / Final-Year Project Value

AquaIntel demonstrates several software engineering concepts:

- Mobile application development
- UI/UX design
- Cloud authentication
- Cloud database management
- CRUD operations
- REST API integration
- Artificial intelligence integration
- Domain-specific AI
- Rule-based decision systems
- Data modelling
- Software testing
- User experience design
- Version control
- Agile development
- Requirements analysis
- Security considerations

The project therefore combines practical software engineering with an applied AI component.

---

# 56. Final Project Summary

**AquaIntel** is a Flutter-based mobile aquarium management application that combines cloud services, structured aquarium data, rule-based decision making, reminders, calculations, and domain-specific AI.

The core idea is to move aquarium management from scattered manual information into one organised application.

The long-term system can be represented as:

```text
                   AQUAINTEL
                       |
        +--------------+--------------+
        |              |              |
   Management       Intelligence   Community
        |              |              |
   Aquariums        AquaBot        Aquarium Posts
   Reminders        Compatibility  Likes
   History          Recommendations Comments
   Water Data       Knowledge
        |
        +--------------+
                       |
                  Firebase
                       |
             +---------+---------+
             |                   |
        Authentication       Firestore
```

The current priority is to build a reliable core system first:

```text
Authentication
      ↓
Aquarium Database
      ↓
Dashboard
      ↓
Compatibility
      ↓
Reminders
      ↓
AquaBot
      ↓
Testing
      ↓
Final Deployment
```

---

# 57. Project Identity

**Project:** AquaIntel  
**Official Title:** AquaIntel: A Domain-Specific AI System for Smart Aquarium Management  
**Platform:** Mobile  
**Framework:** Flutter  
**Language:** Dart  
**Authentication:** Firebase Authentication  
**Database:** Cloud Firestore  
**AI Assistant:** AquaBot  
**Backend:** Python / FastAPI architecture  
**Version Control:** Git / GitHub  
**Project Type:** Final-Year Software Engineering Project

---

## Conclusion

AquaIntel is intended to be more than a simple aquarium information application. Its architecture provides a foundation for a complete digital aquarium management platform where users can store aquarium information, monitor conditions, maintain routines, check compatibility, receive AI assistance, and eventually share their aquariums with a community.

The system is designed to start with practical rule-based and database-driven features and gradually introduce more advanced AI and recommendation capabilities as the project develops.
