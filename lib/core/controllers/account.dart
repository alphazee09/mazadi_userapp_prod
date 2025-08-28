import 'package:mazadi/core/controllers/image_picker.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/account.dart';
import '../models/filter.dart';
import '../repositories/account.dart';
import '../repositories/filter.dart';
import 'location.dart';

class AccountController extends GetxController with StateMixin<dynamic> {
  final account = Account().obs;
  final accountsRepository = Get.find<AccountsRepository>();
  final imagePickerController = Get.find<ImagePickerController>();
  final filtersRepository = Get.find<FiltersRepository>();
  final locationController = Get.find<LocationController>();

  RxInt accountAuctionsCount = 0.obs;
  RxInt activeAuctionsCount = 0.obs;
  RxInt closedAuctionsCount = 0.obs;

  RxInt accountBidsCount = 0.obs;
  RxInt acceptedBidsCount = 0.obs;
  RxInt rejectedBidsCount = 0.obs;

  @override
  void onClose() {
    account.value = Account();
    super.onClose();
  }

  setAccount(Account? account) {
    if (account == null) {
      this.account.value = Account();
      return;
    }
    this.account.value = account;
  }

  updateCoins(int coins) {
    account.value.coins = coins;
    account.refresh();
  }

  Future<bool> loadAccountData(bool purchasesAvailable) async {
    var loadedAccount = await accountsRepository.loadLoggedIn();
    if (loadedAccount == null) {
      return false;
    }

    account.value = loadedAccount;
    loadAccountStats();

    if (purchasesAvailable) {
      await Purchases.logIn(account.value.id);
    }

    if (loadedAccount.locationLatLng != null &&
        loadedAccount.locationPretty != null) {
      locationController.setMarkerLatLong(loadedAccount.locationLatLng);
      locationController.setLocation(loadedAccount.locationPretty ?? '');
    }

    return true;
  }

  Future<void> loadAccountStats() async {
    var accountStats = await accountsRepository.loadStats();
    if (accountStats == null) {
      return;
    }

    updateAccountAuctionsCountFromStats(accountStats);
  }

  Future<void> updateAccountAllowedNotifications(
      AccountNotifications notifications) {
    account.value.allowedNotifications = notifications;
    return accountsRepository.update(account.value);
  }

  Future<bool> deleteAccount() async {
    return await accountsRepository.delete(account.value);
  }

  Future<bool> saveFCMToken(String token) async {
    account.value.deviceFCMToken = token;
    var result = await accountsRepository.update(account.value);
    return result != null;
  }

  Future<void> updateAccountMeta(AccountMetadata meta) {
    account.value.meta = meta;
    account.refresh();
    return accountsRepository.update(account.value);
  }

  Future<void> saveLocationToAccount(LatLng? location, String? prettyLocation) {
    account.value.locationLatLng = location;
    account.value.locationPretty = prettyLocation;
    account.refresh();
    return accountsRepository.update(account.value);
  }

  Future<bool> updateNameAndProfilePicture(String newName) async {
    var galleryAsset = imagePickerController.galleryAssets.isNotEmpty
        ? (await imagePickerController.getGalleryAssetPaths()).first
        : null;

    var cameraAsset = imagePickerController.cameraAssets.isNotEmpty
        ? imagePickerController.cameraAssets.first
        : null;

    account.value.name = newName;
    var updatedAccount = await accountsRepository.update(
      account.value,
      galleryAsset,
      cameraAsset,
    );

    if (updatedAccount != null) {
      account.value.name = newName;
      account.value.picture = updatedAccount.picture;
      account.refresh();
    }
    return updatedAccount != null;
  }

  void togglePreferredCategory(String categoryId) {
    if (categoryIsPreferred(categoryId)) {
      account.value.preferredCategoriesIds.remove(categoryId);
    } else {
      account.value.preferredCategoriesIds.add(categoryId);
    }

    account.refresh();
  }

  bool categoryIsPreferred(String categoryId) {
    return account.value.preferredCategoriesIds.contains(categoryId);
  }

  Future<bool> finishCategoriesSetup() async {
    account.value.categoriesSetupDone = true;
    account.refresh();

    var result = await accountsRepository.update(account.value);
    return result != null;
  }

  Future<Account?> loadAccountDetailsById(String accountId) async {
    return await accountsRepository.loadAccountDetails(accountId);
  }

  Future<bool> finishIntro() async {
    account.value.introDone = true;
    var result = await accountsRepository.update(account.value);
    return result != null;
  }

  Future<bool> skipIntro() async {
    account.value.introSkipped = true;
    var result = await accountsRepository.update(account.value);
    return result != null;
  }

  Future<bool> saveFilterForAccount(FilterItem filterItem) async {
    account.value.filters ??= [];
    account.value.filters!.add(filterItem);
    account.refresh();

    return await filtersRepository.create(filterItem);
  }

  Future<bool> deleteFilterForAccount(String filterId) async {
    var deleted = await filtersRepository.delete(filterId);
    if (deleted == false) {
      return deleted;
    }

    account.value.filters?.removeWhere((element) => element.id == filterId);
    account.refresh();
    return deleted;
  }

  Future<bool> acceptTerms(
    bool acceptedTerms,
  ) async {
    account.value.acceptedTermsAndCondition = acceptedTerms;
    var result = await accountsRepository.update(account.value);
    return result != null;
  }

  bool isFollowingAccount(String accountId) {
    return account.value.followingAccountsIds!.contains(accountId);
  }

  Future<bool> blockAccount(String accountId) async {
    try {
      account.value.blockedAccounts ??= [];
      account.value.blockedAccounts!.add(accountId);
      account.refresh();

      await accountsRepository.blockAccount(accountId);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> unblockAccount(String accountId) async {
    try {
      account.value.blockedAccounts?.remove(accountId);
      account.refresh();

      await accountsRepository.unblockAccount(accountId);
      return true;
    } catch (error) {
      return false;
    }
  }

  void clearAccount() {
    account.value = Account();
  }

  void updateAccountAuctionsCountFromStats(dynamic accountStats) {
    accountAuctionsCount.value = accountStats['auctions'];
    activeAuctionsCount.value = accountStats['activeAuctions'];
    closedAuctionsCount.value = accountStats['closedAuctions'];
    accountBidsCount.value = accountStats['bids'];
    acceptedBidsCount.value = accountStats['acceptedBids'];
    rejectedBidsCount.value = accountStats['rejectedBids'];
  }
}
