---
layout: default
css_id: ecus
---

## Preparing an ECU for Uptane

At the highest level, the basic requirement for an ECU to be capable of supporting Uptane is that it must be able to perform either full or partial verification, and have a secure source of time. (See the [Uptane Standard](https://uptane.github.io/uptane-standard/uptane-standard.html#build-time-prerequisite-requirements-for-ecus) for official requirements.)

To bootstrap an Uptane-capable ECU, a few things need to be provisioned into unit:

* **A current set of Uptane metadata**, so that the ECU is able to verify the first set of metadata it gets from the server. The exact metadata files required depend on whether the ECU performs full or partial verification: full verification ECUs need a complete set of metadata from both repositories; partial verification ECUs only need the Targets metadata from the Director repository.
* **A secure way to know what time it is**, so the ECU can not be tricked into accepting expired metadata. If a [time server](/uptane-standard/uptane-standard.html#time_server) is in use, each ECU would need a recent time downloaded from the time server, and the public key of the time server to verify it. If another source of time is being used, the most important thing is still to make sure that the ECU knows a fairly recent time from the first time it is powered on (or reset to factory settings), to prevent the possibility of freeze attacks.
* **ECU key(s)**, to sign the ECU's [version reports](/uptane-standard/uptane-standard.html#version_report), and optionally to decrypt images. These keys should be unique to the ECU, and the public keys will need to be stored in the Director repository's inventory database.
* **Information about repository locations**, generally in the form of a [repository mapping file](/uptane-standard/uptane-standard.html#repo_mapping_meta). This is a metadata file that tells the ECU the URIs of the repositories (if it's a primary ECU), as well as which images should be fetched from which repository. (Images that are encrypted or customized per-device would generally come from the Director repository, and all others from the Image repository.)

## ECU implementation choices

There are three big decisions to make about each Uptane ECU: first, whether it will perform full verification or partial verification, second, whether it will use an asymmetric or symmetric ECU key, and third, whether it will use encrypted or unencrypted update images. Here, we offer some advice on how to make those choices, and the consequences of those choices.

### Full vs. partial verification

Uptane is designed with automotive requirements in mind, and one of the difficulties in that space is that ECUs requiring OTA updates might have very slow and or memory-limited microcontrollers. To accommodate those ECUs, Uptane includes the option of partial verification. So, how do you choose between full and partial verification for a particular ECU?

Firstly, if the ECU is a primary ECU, partial verification is not an option: it needs to perform full verification. For other ECUs, full verification is preferable when possible, for at least two reasons:

1. Full verification is more secure. Because they don't check image repository metadata, partial verification ECUs could be instructed to install malicious software by an attacker in possession of the Director repository's Targets key (and, of course, a way to send traffic on the relevant in-vehicle bus).
2. Full verification ECUs can rotate keys. Because partial verification is designed for ECUs that can only reasonably check a single signature, they do not download or process root metadata. Since the root metadata is the mechanism for revoking and rotating signing keys for all other metadata, a partial-verification ECU has no truly secure way to invalidate a signing key.

### Symmetric vs. asymmetric ECU keys

<img align="center" src="assets/images/ECU_1_sym_asym.png" width="500" style="margin: 0px 20px"/>

**Figure 1.** *An arrangement that an OEM SHOULD use when using symmetric ECU keys.*

ECUs are permitted to use either symmetric or asymmetric keys. This choice is effectively a performance vs. security trade-off: symmetric keys allow for faster cryptographic operations, but expose a larger attack surface because the Director will need online access to the key. Asymmetric ECU keys are not affected by this problem, because the Director only needs access to the ECU's public key.

Basically, choosing symmetric keys increases the performance of the common case (checking signatures and decrypting images), but makes disaster recovery harder, because a compromised key server could require updating ECU keys on every vehicle.

#### Symmetric key server

If you choose to use symmetric ECU keys, it would be a good idea to store the keys on an isolated, separate key server, rather than in the inventory database. This separate key server can then expose only two very simple operations to the Director:

1. Check the signature on an ECU version report.
2. Given an ECU identifier and an image identifier, encrypt the image for that ECU.

Unencrypted images should be loaded onto the symmetric key server by some out-of-band physical channel (for example, via USB stick).

## Encryption of images on ECUs

The Director repository may encrypt images if required ([Section 5.3.2 of the Uptane Standard](https://github.com/uptane/uptane-standard/blob/master/uptane-standard.md#director-repository-director_repository). However, no Uptane implementation should support interactive requests from an ECU for encryption.  Allowing the
Target ECU to explicitly request an encrypted image at download
time would not only increase the attack surface, but could also be used to turn off encryption. This would make it easy for attackers to reverse engineer unencrypted firmware and steal IPR. Only the OEM and its suppliers should determine policy on
encrypting particular binaries, and this policy should be configured for use by the
Director repository, rather than being toggled by the Target ECU.
