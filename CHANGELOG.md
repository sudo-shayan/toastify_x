# CHANGELOG

## 1.1.0

* **New Feature**: Added `center` position support for toasts.
* **New Feature**: Added `AnimationType` enum with `slide`, `scale`, `fade`, and `bounce` (elastic) transitions.
* **New Feature**: Added `showProgress` parameter to display a linear progress bar within the toast.
* **Feature**: Added support for `customIcon` and `textStyle` overrides.
* **Feature**: Added `padding` and `margin` parameters for layout customization.
- Fixed `withOpacity` deprecation warnings by migrating to `withAlpha`.
- Added a visual preview gallery to the demo app using GIF assets.
* Improved library documentation and code comments.
* Updated README with new styling and performance showcase GIFs.

## 1.0.0

* Initial release of **ToastifyX**.
* Support for multiple Toast types: `success`, `error`, `warning`, `info`, `loading`.
* Support for multiple Styles: `modern`, `minimal`, `glass`, `flat`.
* Position configuration: `top` or `bottom`.
* Backdrop blur for a premium glassmorphic effect.
* Built-in animations with slide and fade transitions.
* Global access using `toastNavigatorKey`.
