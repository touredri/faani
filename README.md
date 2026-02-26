# faani

An application to connect tailor and customer, it promote traditional suit. We can book inside and follow best tailor

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firestore identity rules

This project now includes Firestore rules for durable identity binding between
email and phone:

- `users/{uid}` stores `phoneE164`, `email`, `authProviders`
- `phone_index/{phoneE164}` enforces one phone per uid

Rules file: [firestore.rules](firestore.rules)

Deploy rules:

```bash
npx firebase-tools@latest deploy --only firestore:rules
```

### Firebase CLI compatibility note

If global `firebase` fails with Node compatibility errors, prefer:

```bash
npx firebase-tools@latest <command>
```

Recommended Node versions for Firebase CLI: LTS (`20`, `22`, or `24`).
