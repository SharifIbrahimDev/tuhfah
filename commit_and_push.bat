@echo off
echo ==============================================
echo Committing all 12 changes separately...
echo ==============================================

git add lib/presentation/screens/splash_screen.dart
git commit -m "feat(splash): add author attribution badge on splash screen"

git add lib/presentation/widgets/app_drawer.dart
git commit -m "feat(drawer): add author attribution in drawer header and footer"

git add lib/presentation/widgets/share_card_dialog.dart
git commit -m "feat(share-cards): add author attribution to image export presets and share caption"

git add lib/presentation/screens/toc_screen.dart
git commit -m "feat(toc): display author attribution badge in table of contents header"

git add lib/presentation/screens/home_screen.dart
git commit -m "feat(home): add author attribution to daily hadith share and introductions view"

git add lib/presentation/screens/quiz_screen.dart
git commit -m "feat(quiz): add author attribution banner in quiz setup view"

git add lib/presentation/screens/notes_screen.dart
git commit -m "feat(notes): add author attribution badge in notes empty state"

git add lib/core/pdf_service.dart
git commit -m "feat(pdf): add author attribution in PDF share text and download modal"

git add lib/data/providers/hadith_provider.dart
git commit -m "feat(audio): calibrate speech rate, add repeat loop engine, and source narration"

git add lib/presentation/screens/detail_screen.dart
git commit -m "feat(detail): add audio repeat and speed toolbar controls with author attribution"

git add lib/presentation/screens/settings_screen.dart
git commit -m "feat(settings): add dedicated audio speed and repeat configuration sections"

git add android/gradle.properties
git commit -m "chore(android): update gradle properties for build optimization"

echo ==============================================
echo Pushing all commits to origin main...
echo ==============================================
git push origin main

echo Done! All commits pushed successfully.
pause
