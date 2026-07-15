# ShopLedger refactor TODO

- [ ] Step 1: Inspect remaining key files (drawer/theme/main/pages/home_content) for shop/user naming assumptions.
- [ ] Step 2: Choose target schema: introduce `shopId` (keep backward compatibility with `userId`).
- [ ] Step 3: Add Riverpod dependency and create providers (auth + shop + transactions stream).
- [ ] Step 4: Move transaction aggregation logic (totals, recent, category totals, time filters) into domain/use-cases or view-models.
- [ ] Step 5: Refactor screens to consume providers instead of manual StreamSubscription.
- [ ] Step 6: Fix `ReportingWidget` filter dropdown to actually filter by time range.
- [ ] Step 7: Update FirestoreService to use `shopId` and consistent sorting.
- [ ] Step 8: Update `TransactionModel` mapping (`toMap`/`fromMap`) for `shopId`.
- [ ] Step 9: Update copy/labels from personal finance terms to ShopLedger terms where needed.
- [ ] Step 10: Run `flutter analyze` and `flutter run` to validate.
