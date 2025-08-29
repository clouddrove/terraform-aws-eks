# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.5] - 2025-08-29
### :sparkles: New Features
- [`a72df1b`](https://github.com/clouddrove/terraform-aws-eks/commit/a72df1bc0e5d2133f1d44c54a0ecb826e78d8ad2) - add example for attaching node group to existing EKS cluster *(PR [#77](https://github.com/clouddrove/terraform-aws-eks/pull/77) by [@Arzianghanchi](https://github.com/Arzianghanchi))*

### :bug: Bug Fixes
- [`b00656b`](https://github.com/clouddrove/terraform-aws-eks/commit/b00656be40908773e3d800b961abc64179feb7a8) - Deprecated arguments *(PR [#78](https://github.com/clouddrove/terraform-aws-eks/pull/78) by [@ruchit-sharma09](https://github.com/ruchit-sharma09))*
- [`5eaa9d1`](https://github.com/clouddrove/terraform-aws-eks/commit/5eaa9d19cf5b2214e42318ee40ea904923119e53) - unauthorized error in aws_auth configmap for EKS *(PR [#79](https://github.com/clouddrove/terraform-aws-eks/pull/79) by [@Arzianghanchi](https://github.com/Arzianghanchi))*

### :memo: Documentation Changes
- [`1955c86`](https://github.com/clouddrove/terraform-aws-eks/commit/1955c865a6d7d25f2bba52f593b9a42fccecbd42) - update CHANGELOG.md for 1.4.4 *(commit by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.4.4] - 2025-06-10
### :sparkles: New Features
- [`675b503`](https://github.com/clouddrove/terraform-aws-eks/commit/675b503a973bb99264a23161366e1233a14d0951) - Added EKS Automode Feature *(PR [#76](https://github.com/clouddrove/terraform-aws-eks/pull/76) by [@ruchit-sharma09](https://github.com/ruchit-sharma09))*

### :memo: Documentation Changes
- [`0245d6b`](https://github.com/clouddrove/terraform-aws-eks/commit/0245d6b7aaaa7c499a5aa5440d2d785f594c5f9c) - update CHANGELOG.md for 1.4.3 *(commit by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.4.3] - 2025-04-04
### :sparkles: New Features
- [`2e163bb`](https://github.com/clouddrove/terraform-aws-eks/commit/2e163bb2caf96ee03ddf8d9ec38c580844f0bf65) - custom NodeGroup names without environment prefix *(PR [#69](https://github.com/clouddrove/terraform-aws-eks/pull/69) by [@Arzianghanchi](https://github.com/Arzianghanchi))*
- [`5dbcb0e`](https://github.com/clouddrove/terraform-aws-eks/commit/5dbcb0e2182ee9cd151d2208c1e9c2c535527ea7) - updated branch name in uses of workflow *(PR [#75](https://github.com/clouddrove/terraform-aws-eks/pull/75) by [@clouddrove-ci](https://github.com/clouddrove-ci))*

### :memo: Documentation Changes
- [`a4d89bd`](https://github.com/clouddrove/terraform-aws-eks/commit/a4d89bd9d2fbb3fee77e8986eb4c40b701410790) - update CHANGELOG.md for 1.4.2 *(commit by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.4.2] - 2024-09-04
### :sparkles: New Features
- [`fa4ad11`](https://github.com/clouddrove/terraform-aws-eks/commit/fa4ad11ba153ee8c652943908999a1f4ee4ea30a) - updated branch name in uses of workflow *(PR [#65](https://github.com/clouddrove/terraform-aws-eks/pull/65) by [@rakeshclouddevops](https://github.com/rakeshclouddevops))*

### :bug: Bug Fixes
- [`a48263e`](https://github.com/clouddrove/terraform-aws-eks/commit/a48263e285534befc17e6556bcf042688dccab00) - fix data block, data block was calling before eks cluster creation *(PR [#66](https://github.com/clouddrove/terraform-aws-eks/pull/66) by [@nileshgadgi](https://github.com/nileshgadgi))*

### :memo: Documentation Changes
- [`afab46b`](https://github.com/clouddrove/terraform-aws-eks/commit/afab46b2a83c4dd72d9a940881cc2cb5aa4a82bb) - update CHANGELOG.md for 1.4.1 *(commit by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.4.1] - 2024-05-07
### :sparkles: New Features
- [`965397c`](https://github.com/clouddrove/terraform-aws-eks/commit/965397c8d9fbe80d079dc4134b028b16c60da607) - update github-action version and added automerge file *(PR [#61](https://github.com/clouddrove/terraform-aws-eks/pull/61) by [@theprashantyadav](https://github.com/theprashantyadav))*
- [`cfd2b41`](https://github.com/clouddrove/terraform-aws-eks/commit/cfd2b411629688901588c768c59c93be8447b773) - updated example path and readme paramters *(commit by [@Tanveer143s](https://github.com/Tanveer143s))*

### :bug: Bug Fixes
- [`5268f7c`](https://github.com/clouddrove/terraform-aws-eks/commit/5268f7ca95d02aa1639fa8a4a6f1af836ab95973) - Update kubernetes provider name and tag. *(PR [#64](https://github.com/clouddrove/terraform-aws-eks/pull/64) by [@nileshgadgi](https://github.com/nileshgadgi))*

### :memo: Documentation Changes
- [`9824ae1`](https://github.com/clouddrove/terraform-aws-eks/commit/9824ae1dff440241a1d975b866795d27b000e444) - update CHANGELOG.md for 1.4.0 *(commit by [@clouddrove-ci](https://github.com/clouddrove-ci))*


## [1.4.0] - 2023-09-18
### :sparkles: New Features
- [`416b3a6`](https://github.com/clouddrove/terraform-aws-eks/commit/416b3a69851bd662faa42ddda561331df3f12c11) - added default eks addons *(commit by [@h1manshu98](https://github.com/h1manshu98))*
- [`4ee24c4`](https://github.com/clouddrove/terraform-aws-eks/commit/4ee24c44638bf4f33a970c2a0605e383aac19f96) - added default eks addons *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`a63cc9a`](https://github.com/clouddrove/terraform-aws-eks/commit/a63cc9a42ff60c4e969586aea916446c4d73d3e7) - added default eks addons *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`0854828`](https://github.com/clouddrove/terraform-aws-eks/commit/08548281013efceb2bc58ecfa2b8b7f735bd76dc) - added default eks addons *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`9cc2ba8`](https://github.com/clouddrove/terraform-aws-eks/commit/9cc2ba84d7c38127049c92f360e48ff2aa9e19dc) - added default eks addons *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`114b2b4`](https://github.com/clouddrove/terraform-aws-eks/commit/114b2b4d90ac37ac20587f7e0c6182332d10af76) - added default eks addons *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`b707e3e`](https://github.com/clouddrove/terraform-aws-eks/commit/b707e3e9a376171feff3a8fe5dca69eef0d59b0a) - added default eks addons *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`cbeab87`](https://github.com/clouddrove/terraform-aws-eks/commit/cbeab870f2456b60e952f75fdac208b95fb1fcf8) - added default eks addons *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`abe8d90`](https://github.com/clouddrove/terraform-aws-eks/commit/abe8d90fd1138ac841fed3bf35b878f0e1012435) - fargate profile added *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`1e4c37a`](https://github.com/clouddrove/terraform-aws-eks/commit/1e4c37abddbecd6f87337c1700f77df852ea5c2f) - fargate profile added *(commit by [@anmolnagpal](https://github.com/anmolnagpal))*
- [`25c9650`](https://github.com/clouddrove/terraform-aws-eks/commit/25c9650645ce130ba13f95cf9ba89850fc7f98ce) - default variable removed *(commit by [@d4kverma](https://github.com/d4kverma))*
- [`8afa1d5`](https://github.com/clouddrove/terraform-aws-eks/commit/8afa1d543e7adf82601565d06445cd6d3e95eea6) - version fixed *(commit by [@d4kverma](https://github.com/d4kverma))*
- [`71b27cd`](https://github.com/clouddrove/terraform-aws-eks/commit/71b27cd7af357fb07b81f665a46a29daa1d465cf) - version fixed *(commit by [@d4kverma](https://github.com/d4kverma))*
- [`9b4604d`](https://github.com/clouddrove/terraform-aws-eks/commit/9b4604d303fdc9a8d365dcb262bd57a35bac8349) - additional tags for public and private subnets *(PR [#58](https://github.com/clouddrove/terraform-aws-eks/pull/58) by [@h1manshu98](https://github.com/h1manshu98))*

### :bug: Bug Fixes
- [`24b6c49`](https://github.com/clouddrove/terraform-aws-eks/commit/24b6c493f79176998d4073325feaed7313e15f6e) - Enabled key rotation in fargate example *(commit by [@13archit](https://github.com/13archit))*
- [`10c3a9b`](https://github.com/clouddrove/terraform-aws-eks/commit/10c3a9b32e46a427568399ac9d6a38528d054eee) - Fixed tfsec ignore *(commit by [@13archit](https://github.com/13archit))*
- [`3ea65e5`](https://github.com/clouddrove/terraform-aws-eks/commit/3ea65e562627f93eb4b13f458c59e3b7c9331e76) - Added tfsec ignore *(commit by [@13archit](https://github.com/13archit))*
- [`1bbff08`](https://github.com/clouddrove/terraform-aws-eks/commit/1bbff08dc43595c328337e27b3c207948dea3a6f) - fix tflint workflow. *(commit by [@13archit](https://github.com/13archit))*
- [`72abff5`](https://github.com/clouddrove/terraform-aws-eks/commit/72abff5743e388fd635f3b25e4b1da97bd7c0e9a) - removed keypair module *(commit by [@h1manshu98](https://github.com/h1manshu98))*
- [`eef6961`](https://github.com/clouddrove/terraform-aws-eks/commit/eef69618d577be864c5d0a1624448df54fc0f7bd) - removed keypair module *(commit by [@h1manshu98](https://github.com/h1manshu98))*
- [`3c6b476`](https://github.com/clouddrove/terraform-aws-eks/commit/3c6b4760d91280824075588215a1270cf6cd67ea) - removed keypair module *(commit by [@h1manshu98](https://github.com/h1manshu98))*


## [0.15.2] - 2022-07-05

## [1.0.1] - 2022-07-29

## [0.12.9.2] - 2022-04-26

## [1.0.0] - 2022-03-30

## [0.15.1] - 2021-12-10

## [0.15.0.1] - 2021-11-11

## [0.12.10.1] - 2021-09-03

## [0.12.13.1] - 2021-07-22

## [0.12.9.1] - 2021-07-22

## [0.15.0] - 2021-06-30

## [0.12.6.1] - 2021-03-25

## [0.13.0] - 2020-11-03

## [0.12.13] - 2020-11-02

## [0.12.12] - 2020-11-02

## [0.12.11] - 2020-09-29

## [0.12.10] - 2020-09-08

## [0.12.9] - 2020-07-15

## [0.12.8] - 2020-07-14

## [0.12.7] - 2020-07-02

## [0.12.6] - 2020-05-24

## [0.12.5] - 2020-03-05

## [0.12.4] - 2019-12-30

## [0.12.3] - 2019-12-05

## [0.12.2] - 2019-12-02

## [0.12.0] - 2019-11-08


[0.12.0]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.0...master
[0.12.2]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.2...master
[0.12.3]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.3...master
[0.12.4]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.4...master
[0.12.5]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.5...master
[0.12.6]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.6
[0.12.7]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.7...master
[0.12.8]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.8
[0.12.9]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.9...master
[0.12.10]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.10...master
[0.12.11]: https://github.com/clouddrove/terraform-aws-eks/compare/0.12.11...master
[0.12.12]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.12
[0.12.13]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.13
[0.13.0]: https://github.com/clouddrove/terraform-aws-eks/compare/0.13.0...master
[0.12.6.1]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.6.1
[0.15.0]: https://github.com/clouddrove/terraform-aws-eks/compare/0.15.0...master
[0.12.9.1]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.9.1
[0.12.13.1]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.13.1
[0.12.10.1]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.10.1
[0.15.0.1]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.15.0.1
[0.15.1]: https://github.com/clouddrove/terraform-aws-eks/compare/0.15.1...master
[1.0.0]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/1.0.0
[0.12.9.2]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.12.9.2
[1.0.1]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/1.0.1
[0.15.2]: https://github.com/clouddrove/terraform-aws-eks/releases/tag/0.15.2
[1.4.0]: https://github.com/clouddrove/terraform-aws-eks/compare/1.3.0...1.4.0
[1.4.1]: https://github.com/clouddrove/terraform-aws-eks/compare/1.4.0...1.4.1
[1.4.2]: https://github.com/clouddrove/terraform-aws-eks/compare/1.4.1...1.4.2
[1.4.3]: https://github.com/clouddrove/terraform-aws-eks/compare/1.4.2...1.4.3
[1.4.4]: https://github.com/clouddrove/terraform-aws-eks/compare/1.4.3...1.4.4
[1.4.5]: https://github.com/clouddrove/terraform-aws-eks/compare/1.4.4...1.4.5
