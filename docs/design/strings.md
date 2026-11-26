# PurgeSwipe — Copy per screen (source `en`, localized `vi`)

Keys are suggestions for `Localizable.xcstrings`; sentence case, no emoji, no superlatives.

## Onboarding (`Features/Onboarding`)
| Key | en | vi |
|---|---|---|
| `onboarding.title` | Clear your photo library, one swipe at a time. | Dọn thư viện ảnh, mỗi lần một cú vuốt. |
| `onboarding.body` | Everything happens on your iPhone. No account. No cloud. | Mọi thứ diễn ra trên iPhone của bạn. Không tài khoản. Không đám mây. |
| `onboarding.choose_photos` | Choose photos | Chọn ảnh |
| `onboarding.not_now` | Not now | Để sau |

## Home (`Features/Home`)
| Key | en | vi |
|---|---|---|
| `home.title` | Cleanup | Dọn dẹp |
| `home.library.label` | Photo library | Thư viện ảnh |
| `home.library.detail` | 18,432 items · On this iPhone | 18.432 mục · Trên iPhone này |
| `home.section.decks` | Decks | Bộ ảnh |
| `deck.screenshots` | Screenshots | Ảnh chụp màn hình |
| `deck.similar` | Similar shots | Ảnh gần giống |
| `deck.blurry` | Blurry photos | Ảnh mờ |
| `deck.videos` | Large videos | Video lớn |
| `common.items` | %lld items | %lld mục |
| `common.pro` | Pro | Pro |
| `home.last_cleanup.title` | Last cleanup | Lần dọn gần nhất |
| `home.last_cleanup.detail` | 96 photos · 1.8 GB moved to Recently Deleted | 96 ảnh · 1,8 GB đã chuyển vào Mục đã xoá gần đây |
| `common.ad` | Ad | Quảng cáo |

## Swipe deck (`Features/Deck`)
| Key | en | vi |
|---|---|---|
| `deck.progress` | %1$lld of %2$lld | %1$lld trên %2$lld |
| `deck.to_delete` | %lld to delete | %lld ảnh sẽ xoá |
| `deck.keep` | Keep | Giữ |
| `deck.delete` | Delete | Xoá |
| `deck.undo` | Undo | Hoàn tác |

## Review and delete (`Features/Review`)
| Key | en | vi |
|---|---|---|
| `review.title` | Review | Xem lại |
| `review.summary` | %1$lld photos · %2$@ | %1$lld ảnh · %2$@ |
| `review.body` | These items move to Recently Deleted after you confirm. | Các mục này sẽ được chuyển vào Mục đã xoá gần đây sau khi bạn xác nhận. |
| `review.delete` | Delete %lld photos | Xoá %lld ảnh |

## Paywall (`StoreKit`)
| Key | en | vi |
|---|---|---|
| `paywall.title` | PurgeSwipe Pro | PurgeSwipe Pro |
| `paywall.benefit.unlimited` | Unlimited deletions | Xoá không giới hạn |
| `paywall.benefit.groups` | All similar and blurry groups | Tất cả nhóm ảnh giống và mờ |
| `paywall.benefit.videos` | Large videos | Video lớn |
| `paywall.benefit.noads` | No ads | Không quảng cáo |
| `paywall.plan.yearly` | Yearly | Hàng năm |
| `paywall.plan.monthly` | Monthly | Hàng tháng |
| `paywall.plan.lifetime` | Lifetime | Vĩnh viễn |
| `paywall.trial` | 3-day free trial | Dùng thử miễn phí 3 ngày |
| `paywall.terms` | 3-day free trial, then %@. Cancel anytime. | 3 ngày miễn phí, sau đó %@. Huỷ bất cứ lúc nào. |
| `paywall.continue` | Continue | Tiếp tục |
| `common.restore` | Restore Purchases | Khôi phục giao dịch |
| `paywall.legal` | Privacy Policy · Terms of Use (EULA) | Chính sách quyền riêng tư · Điều khoản sử dụng (EULA) |

## Settings (`Features/Settings`)
| Key | en | vi |
|---|---|---|
| `settings.title` | Settings | Cài đặt |
| `settings.section.pro` | Pro | Pro |
| `settings.plan.free` | Free plan | Gói miễn phí |
| `settings.view_plans` | View Plans | Xem các gói |
| `settings.manage` | Manage Subscription | Quản lý đăng ký |
| `settings.section.appearance` | Appearance | Giao diện |
| `settings.appearance.system` | System | Hệ thống |
| `settings.appearance.light` | Light | Sáng |
| `settings.appearance.dark` | Dark | Tối |
| `settings.section.help` | Help | Trợ giúp |
| `settings.help` | Help and FAQ | Trợ giúp và FAQ |
| `settings.privacy` | Privacy Policy | Chính sách quyền riêng tư |
| `settings.terms` | Terms of Use | Điều khoản sử dụng |
| `settings.about` | About | Giới thiệu |

Prices are never hardcoded: `Product.displayPrice` / `SubscriptionStoreView` supply them at runtime; the mock values ($19.99/year, $4.99/month, $29.99 one-time) exist only to verify layout.
Vietnamese strings run ~30 % longer; every row must survive at AX3 with the same layout and reflow to `VStack` at AX4+.
