# CR Assistant

## Batch notices

The app uses FCM topics named
`university_dept_batch_batchName` (for example, `du_cse_batch_55`). Students
subscribe after login and register their current FCM token with
`POST /api/v1/auth/fcm-token` using the authenticated session.

When the authenticated notice API accepts a CR notice, it should create a
Firestore document at `notices/{noticeId}` with this shape:

```json
{
	"title": "Exam notice",
	"description": "The exam starts at 10:00.",
	"batchId": 55,
	"universityName": "DU",
	"deptName": "CSE",
	"batchName": "55",
	"createdByRole": "CR",
	"createdAt": "server timestamp"
}
```

The `functions/sendBatchNotice` trigger normalizes the three batch fields and
sends the notification to the resulting topic. The API must authenticate the
bearer token and derive `batchId`, the three batch fields, and `createdByRole`
from the server-side user record; never trust those values from the client when
creating the Firestore document. This keeps a CR from publishing into another
batch. Deploy it with `firebase deploy --only functions` from the project root
after installing dependencies in `functions`.

The existing REST `/notices` response remains the source for the in-app notice
list. The REST notice handler and the Firestore write should be part of the
same backend operation, or the handler can use the Firestore document ID as
the notice ID returned to the app.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
