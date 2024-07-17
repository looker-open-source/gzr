# Changelog

## [0.3.17](https://github.com/looker-open-source/gzr/compare/v0.3.16...v0.3.17) (2024-07-17)


### Bug Fixes

* continue after 403 error on dashboard cat getting alerts if user is not admin ([#255](https://github.com/looker-open-source/gzr/issues/255)) ([6cbb69f](https://github.com/looker-open-source/gzr/commit/6cbb69f7e30ee7d06c54037d3ba484a7f17306d6))

## [0.3.16](https://github.com/looker-open-source/gzr/compare/v0.3.15...v0.3.16) (2024-06-27)


### Features

* randomize a specific alert by alert_id ([0e9cf40](https://github.com/looker-open-source/gzr/commit/0e9cf401346845d4f740a75379161cecddf1669b))
* randomize a specific plan by plan_id ([99d30f1](https://github.com/looker-open-source/gzr/commit/99d30f1747eafa81989bfd3bfc728c5a367fc1e3))

## [0.3.15](https://github.com/looker-open-source/gzr/compare/v0.3.14...v0.3.15) (2024-06-12)


### Features

* Alert randomization ([f367d8e](https://github.com/looker-open-source/gzr/commit/f367d8e5e0d164cf5cf1d9b7e79ed93fd2c0ea62))
* Plan randomization ([3176fe0](https://github.com/looker-open-source/gzr/commit/3176fe0032c237adcb7b95d821e0f54323e19221))

## [0.3.14](https://github.com/looker-open-source/gzr/compare/v0.3.13...v0.3.14) (2024-03-11)


### Bug Fixes

* typo NotFoud error ([f391d43](https://github.com/looker-open-source/gzr/commit/f391d43dc75f4a06f89cb13b7c4200d870d77b49))

## [0.3.13](https://github.com/looker-open-source/gzr/compare/v0.3.12...v0.3.13) (2024-02-20)


### Bug Fixes

* clean up eval code ([b478a45](https://github.com/looker-open-source/gzr/commit/b478a45327ddf1e48441e780c54ad280822d736c))
* remove eval from lib/gzr/commands/alert/ls.rb ([5a3e53a](https://github.com/looker-open-source/gzr/commit/5a3e53a528b9f05ff86716980f435c0225ecb6b5))
* remove eval from lib/gzr/commands/alert/notifications.rb ([1a06c3c](https://github.com/looker-open-source/gzr/commit/1a06c3ca9541e049f93ae9bb5eccb31d639437fa))
* remove eval from lib/gzr/commands/attribute/ls.rb ([5bc8051](https://github.com/looker-open-source/gzr/commit/5bc80514d88bfb344d90f1a736521354774c63f2))
* remove eval from lib/gzr/commands/connection/dialects.rb ([1a45294](https://github.com/looker-open-source/gzr/commit/1a45294a4e97f714c7d523d8bf6e8a01c5341380))
* remove eval from lib/gzr/commands/connection/ls.rb ([87e36f8](https://github.com/looker-open-source/gzr/commit/87e36f8223f9585938b9c33d06b18055f2f78de2))
* remove eval from lib/gzr/commands/connection/test.rb ([70f1e27](https://github.com/looker-open-source/gzr/commit/70f1e274cad6fa2506d07afb24f54ca6474e89de))
* remove eval from lib/gzr/commands/folder/top.rb ([42740d2](https://github.com/looker-open-source/gzr/commit/42740d23a4771ffb98e732322882104960dc5949))
* remove eval from lib/gzr/commands/group/ls.rb ([21e0169](https://github.com/looker-open-source/gzr/commit/21e016960f6c3e30885c830817a84c351c0e77c4))
* remove eval from lib/gzr/commands/group/member_groups.rb ([e4b20b3](https://github.com/looker-open-source/gzr/commit/e4b20b37a8935efd21a654ed88653f96ba87c446))
* remove eval from lib/gzr/commands/group/member_users.rb ([956ac4e](https://github.com/looker-open-source/gzr/commit/956ac4eb967266f9829a80f4f21d6b0cc9442577))
* remove eval from lib/gzr/commands/model/ls.rb ([8d23a68](https://github.com/looker-open-source/gzr/commit/8d23a687cc23fe4827ab6597054f6420a954513d))
* remove eval from lib/gzr/commands/model/set/ls.rb ([596f60a](https://github.com/looker-open-source/gzr/commit/596f60aaac0570874771aee5e12cdcb746a0fd8b))
* remove eval from lib/gzr/commands/permission/ls.rb ([b79897b](https://github.com/looker-open-source/gzr/commit/b79897b1915a9fb7dd265b27ba7c507af07dc620))
* remove eval from lib/gzr/commands/permission/set/ls.rb ([f47916d](https://github.com/looker-open-source/gzr/commit/f47916d396d8c01484d7d24f183b342736282f7f))
* remove eval from lib/gzr/commands/plan/failures.rb ([b912249](https://github.com/looker-open-source/gzr/commit/b9122494ff2f4dd2d9d5294df6f0900d5fd60983))
* remove eval from lib/gzr/commands/plan/ls.rb ([84e74f4](https://github.com/looker-open-source/gzr/commit/84e74f439f327fb8e4faa74dcc6d166a016573b2))
* remove eval from lib/gzr/commands/project/branch.rb ([2b36a27](https://github.com/looker-open-source/gzr/commit/2b36a2757e9edd0e7305ecc8dea2ff6ba01fc5c8))
* remove eval from lib/gzr/commands/project/ls.rb ([70e80d6](https://github.com/looker-open-source/gzr/commit/70e80d6253ced09fd9ec96918f8eed90f5f1d4c6))
* remove eval from lib/gzr/commands/role/group_ls.rb ([43dd2ec](https://github.com/looker-open-source/gzr/commit/43dd2eca15211bcf0032b006de71a9b85a225ba9))
* remove eval from lib/gzr/commands/role/ls.rb ([fae96e7](https://github.com/looker-open-source/gzr/commit/fae96e7c99fdd27d3bd141ae334eaa8cf6ba572b))
* remove eval from lib/gzr/commands/role/user_ls.rb ([6a53980](https://github.com/looker-open-source/gzr/commit/6a53980eb7a407bce9d163b6fb6264c03c64b623))
* remove eval from lib/gzr/commands/user/me.rb ([af070e3](https://github.com/looker-open-source/gzr/commit/af070e3b8f7aa4acbc11e3665b94a203c3a1962e))
* use query_slug in merge query api ([beb1524](https://github.com/looker-open-source/gzr/commit/beb152409d43032d45299cf4687031254d27872c))

## [0.3.12](https://github.com/looker-open-source/gzr/compare/v0.3.11...v0.3.12) (2023-10-04)


### Bug Fixes

* called row element with wrong method ([e1b7bf7](https://github.com/looker-open-source/gzr/commit/e1b7bf7e0f0873dd4655ae8cd01d25d2ca978db2))

## [0.3.11](https://github.com/looker-open-source/gzr/compare/v0.3.10...v0.3.11) (2023-09-29)


### Features

* Tech debt removal for better testing ([#223](https://github.com/looker-open-source/gzr/issues/223)) ([e3a7e88](https://github.com/looker-open-source/gzr/commit/e3a7e889fe020a4a1a5f496b634b11cf96c3028f))

## [0.3.10](https://github.com/looker-open-source/gzr/compare/v0.3.9...v0.3.10) (2023-06-28)


### Bug Fixes

* Faraday 2.x ([bdc5e52](https://github.com/looker-open-source/gzr/commit/bdc5e5205c1be21d76b93624f193fadb8a1b32b3))

## [0.3.9](https://github.com/looker-open-source/gzr/compare/v0.3.8...v0.3.9) (2023-05-25)


### Bug Fixes

* model import handles case where model already exists ([302b4db](https://github.com/looker-open-source/gzr/commit/302b4db60ecf0a3b5fc92c34f1fd36f9afaf8f40))

## [0.3.8](https://github.com/looker-open-source/gzr/compare/v0.3.7...v0.3.8) (2023-05-16)


### Features

* create role command ([#204](https://github.com/looker-open-source/gzr/issues/204)) ([cba4a80](https://github.com/looker-open-source/gzr/commit/cba4a803af8298915ca0e2189919d542bfd9f982))
* management of model sets ([#200](https://github.com/looker-open-source/gzr/issues/200)) ([1b964ca](https://github.com/looker-open-source/gzr/commit/1b964ca25cf7eb55ff211dab6ae48c174ad3f4b6))
* Permission Set management ([#203](https://github.com/looker-open-source/gzr/issues/203)) ([ef7355c](https://github.com/looker-open-source/gzr/commit/ef7355c41234928996540f2c6ed50ba358e197b7))
* show available permissions in tree format ([#202](https://github.com/looker-open-source/gzr/issues/202)) ([c702a64](https://github.com/looker-open-source/gzr/commit/c702a64a5247fb151b155d1c6d1116cb20cccc0f))

## [0.3.7](https://github.com/looker-open-source/gzr/compare/v0.3.6...v0.3.7) (2023-05-10)


### Features

* option to sync lookml dashboard on import_lookml if it exists already ([#196](https://github.com/looker-open-source/gzr/issues/196)) ([c8ec619](https://github.com/looker-open-source/gzr/commit/c8ec619186c6a0ce81633d701f78444f4e488a5b))


### Bug Fixes

* Update connection calling wrong API method ([#197](https://github.com/looker-open-source/gzr/issues/197)) ([e122b47](https://github.com/looker-open-source/gzr/commit/e122b47fca9f2ff218cff0904c147cf94d54fe69))

## [0.3.6](https://github.com/looker-open-source/gzr/compare/v0.3.5...v0.3.6) (2023-05-09)


### Features

* dashboard sync_lookml to sync UDDs with their associated lookml dashboards ([#194](https://github.com/looker-open-source/gzr/issues/194)) ([7b94a79](https://github.com/looker-open-source/gzr/commit/7b94a7962d36d865759b105b481f602aac87523e))

## [0.3.5](https://github.com/looker-open-source/gzr/compare/v0.3.4...v0.3.5) (2023-05-05)


### Features

* dashboard import_lookml ([#192](https://github.com/looker-open-source/gzr/issues/192)) ([248d5eb](https://github.com/looker-open-source/gzr/commit/248d5eb4b9e1c9ae302ab1b598784dd5065e9bf0))

## [0.3.4](https://github.com/looker-open-source/gzr/compare/v0.3.3...v0.3.4) (2023-05-04)


### Features

* More project and model commands ([#190](https://github.com/looker-open-source/gzr/issues/190)) ([2d05d00](https://github.com/looker-open-source/gzr/commit/2d05d00a13721fdde733aecb6c99985ee5a1b081))

## [0.3.3](https://github.com/looker-open-source/gzr/compare/v0.3.2...v0.3.3) (2023-05-02)


### Features

* Connection handling with Gazer ([#184](https://github.com/looker-open-source/gzr/issues/184)) ([346c9b7](https://github.com/looker-open-source/gzr/commit/346c9b7ea846acd604dbe929fab71e2ae0a5cf71))
* get and create deplpy keys for git. ([7b4a9e2](https://github.com/looker-open-source/gzr/commit/7b4a9e225596f54b6ec58d4923ac9e3d73106bd6))
* import and update a project ([#186](https://github.com/looker-open-source/gzr/issues/186)) ([825ab29](https://github.com/looker-open-source/gzr/commit/825ab297e99b4c09721bda3c72fce969fd16c5e8))
* Persistent tokens for login ([#182](https://github.com/looker-open-source/gzr/issues/182)) ([482c00f](https://github.com/looker-open-source/gzr/commit/482c00f4cb40519a3d3e7aac771e3b52c553e5d1))
* Project management and session management additions ([#185](https://github.com/looker-open-source/gzr/issues/185)) ([0093a60](https://github.com/looker-open-source/gzr/commit/0093a6057bd953773939fdf901631bab0e9109c6))


### Bug Fixes

* wrong method called in project update ([165630d](https://github.com/looker-open-source/gzr/commit/165630d3dabbe2947a22a439e54f6692d21e013a))

## [0.3.2](https://github.com/looker-open-source/gzr/compare/v0.3.1...v0.3.2) (2023-04-21)


### Features

* Alerts management through gazer ([#180](https://github.com/looker-open-source/gzr/issues/180)) ([74d0307](https://github.com/looker-open-source/gzr/commit/74d0307d63602df5efad98e7c8e92b91740a4afc))

## [0.3.1](https://github.com/looker-open-source/gzr/compare/v0.3.0...v0.3.1) (2023-04-20)


### Features

* Add --trim option for dashboard cat, look cat, and folder export commands ([#178](https://github.com/looker-open-source/gzr/issues/178)) ([3173796](https://github.com/looker-open-source/gzr/commit/317379600803cfb92d223980930c0831fe8c247d))

## [0.3.0](https://github.com/looker-open-source/gzr/compare/v0.2.60...v0.3.0) (2023-04-13)


### Features

* Misc fixes ([#175](https://github.com/looker-open-source/gzr/issues/175)) ([20b334b](https://github.com/looker-open-source/gzr/commit/20b334b3e4d1a76ecef79d5c686f6cf428cdc47d))


### Miscellaneous Chores

* release 0.3.0 ([5ed2182](https://github.com/looker-open-source/gzr/commit/5ed2182b94c20126f59b0678671d7c9b81c1c794))

### [0.2.60](https://www.github.com/looker-open-source/gzr/compare/v0.2.59...v0.2.60) (2023-04-11)


### Bug Fixes

* quick typo fixes for API 4.0 changes ([#168](https://www.github.com/looker-open-source/gzr/issues/168)) ([82a634e](https://www.github.com/looker-open-source/gzr/commit/82a634e77de0aaee5bd62c84092e827a2f7f6c73))

### [0.2.59](https://www.github.com/looker-open-source/gzr/compare/v0.2.58...v0.2.59) (2023-03-29)


### Bug Fixes

* migrate to API 4.0 ([#154](https://www.github.com/looker-open-source/gzr/issues/154)) ([eecdfd4](https://www.github.com/looker-open-source/gzr/commit/eecdfd41a886f2edbac528a34f83dc7a6ea83f74))

### [0.2.58](https://www.github.com/looker-open-source/gzr/compare/v0.2.57...v0.2.58) (2023-03-16)


### Bug Fixes

* temporary fix for faraday 2.x in looker-sdk ([#159](https://www.github.com/looker-open-source/gzr/issues/159)) ([d89f813](https://www.github.com/looker-open-source/gzr/commit/d89f8138587c2986352be25b59bda79d07ea2bb4))

### [0.2.57](https://www.github.com/looker-open-source/gzr/compare/v0.2.56...v0.2.57) (2023-03-16)


### Bug Fixes

* temporary fix for faraday 2.x in looker-sdk ([acdb7e8](https://www.github.com/looker-open-source/gzr/commit/acdb7e8a174cd3dde5d8c95c95e572ec331b948f))

### [0.2.56](https://www.github.com/looker-open-source/gzr/compare/v0.2.55...v0.2.56) (2022-07-14)

### Bug Fixes

- release version ([c94373c](https://www.github.com/looker-open-source/gzr/commit/c94373ce0677b4bd86e525f6a7e15b0204cb69fe))

### [0.2.55](https://github.com/looker-open-source/gzr/compare/v0.2.54...v0.2.55) (2022-07-14)

### Bug Fixes

- Added alias for folder command to point to space. ([#133](https://github.com/looker-open-source/gzr/issues/133)) ([e54ffe0](https://github.com/looker-open-source/gzr/commit/e54ffe0c8c1ba300b5d989c5b16b8a234e9623b1))
- For dashboard cat with --plans ([#131](https://github.com/looker-open-source/gzr/issues/131)) ([59c961d](https://github.com/looker-open-source/gzr/commit/59c961dca820654c8ca228fc79429079ac4825bd))

### [0.2.54](https://www.github.com/looker-open-source/gzr/compare/v0.2.53...v0.2.54) (2022-03-17)

### Bug Fixes

- Avoid API 4.0 for deprecation of spaces endpoint ([#124](https://www.github.com/looker-open-source/gzr/issues/124)) ([#125](https://www.github.com/looker-open-source/gzr/issues/125)) ([3823399](https://www.github.com/looker-open-source/gzr/commit/38233991bfc5456ac0cf3d485d12520f50a2ea76))

### [0.2.53](https://www.github.com/looker-open-source/gzr/compare/v0.2.52...v0.2.53) (2021-12-14)

### Bug Fixes

- fix version ([#121](https://www.github.com/looker-open-source/gzr/issues/121)) ([f9b0b22](https://www.github.com/looker-open-source/gzr/commit/f9b0b2237eb3c520aabc2f1ff5a63ddf6c934ce4))

### [0.2.52](https://www.github.com/looker-open-source/gzr/compare/v0.2.51...v0.2.52) (2021-12-14)

### Bug Fixes

- version number ([#119](https://www.github.com/looker-open-source/gzr/issues/119)) ([b55a892](https://www.github.com/looker-open-source/gzr/commit/b55a892d8d040ce4547924d613a590877e129322))

### [0.2.51](https://www.github.com/looker-open-source/gzr/compare/v0.2.50...v0.2.51) (2021-12-14)

### Bug Fixes

- detect if dashboard import gets a look file and vice versa, warn on importing a deleted dashboard or look ([#116](https://www.github.com/looker-open-source/gzr/issues/116)) ([a12dc25](https://www.github.com/looker-open-source/gzr/commit/a12dc2525bed55816b368306f2d05a24dc07aaf4))
- Gemfile.lock was out of date ([a4e49c3](https://www.github.com/looker-open-source/gzr/commit/a4e49c3972772e0629a8f1589172ddd136ee7e21))
- refactored look and dashboard cat commands and space export to use the same code to generate each look and dashboard file. ([#114](https://www.github.com/looker-open-source/gzr/issues/114)) ([8dadd50](https://www.github.com/looker-open-source/gzr/commit/8dadd500376e2b971c38dbcd69f507268a3e6b9e))
- remove Thor deprecation warning ([#115](https://www.github.com/looker-open-source/gzr/issues/115)) ([1100c5a](https://www.github.com/looker-open-source/gzr/commit/1100c5a24b0626c01c6248d87172c7ab624bf42f))

### [0.2.50](https://www.github.com/looker-open-source/gzr/compare/v0.2.49...v0.2.50) (2021-11-19)

### Bug Fixes

- resolved warnings in gemspec. Improved handling of live tests ([6291147](https://www.github.com/looker-open-source/gzr/commit/6291147a09f55ed095d718a7a998d5af09b716e3))

### [0.2.49](https://www.github.com/looker-open-source/gzr/compare/v0.2.48...v0.2.49) (2021-11-18)

### Bug Fixes

- Bump version ([652486c](https://www.github.com/looker-open-source/gzr/commit/652486ce6571d4fea2d3ea847c5927395aa4373e))

### [0.2.48](https://www.github.com/looker-open-source/gzr/compare/v0.2.47...v0.2.48) (2021-11-18)

### Bug Fixes

- Add release please workflow to automate releases ([6279bc6](https://www.github.com/looker-open-source/gzr/commit/6279bc68fcfd8f09f7385053767e6a9571570333))
