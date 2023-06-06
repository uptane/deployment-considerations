---
layout: default
css_id: changelog
---

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2023-06-6
V.2.1.0 is a minor release containing no breaking changes. The changes it includes, which are detailed below, are largely wording clarifications. The most significant addition is referencing the Scudo option as an augmentation for software supply chain security in automobiles. 

### Added
- A clearer definition of the term “conformant” as it applies to Uptane.
- A security policy that outlines how errata can be reported and how reports will be addressed.
- A  file stating that the Uptane Standard and Deployment Best Practices is licensed under Apache.
- A mention of Scudo as an Uptane augmentation in the “Out of Scope” text in the Standard as a clarification of Uptane’s involvement in software supply chain security.  
### Changed
- The term  “Uptane-compliant” to “Uptane-conformant” to clarify that the framework is a standard to follow rather than a regulation that must be adhered to. 
- Metadata distribution requirements for secondaries to allow more flexibility when there are no new downloads for a given ECU. 
- Relaxed the requirement that verification of Targets metadata be considered complete if the Directory repository indicates that there are no new targets. 
- Relaxed the requirement that the Director repository SHALL check the time sent in the ECU report to a SHOULD.

### Removed
- All mentions of the Reference Implementation, which has now been clearly marked as obsolete.
- The term “private key” to reduce confusion about the role of these keys.
- Removed redundant and unclear wording from the description of the Root role in Section 5.1.1. 


## [2.0.0] - 2022-01-18
As the first major release since 1.0.0 was issued on July 31, 2019, the new version contains several breaking changes that could affect backwards compatibility. However, several of these changes also provide greater flexibility for the implementer. Probably the most significant change was removing references to the Uptane Time Server, to clarify that users can make their own decisions about secure sources of time, as long as it is reliable. On the whole, V.2.0.0 should make implementation on legacy systems easier rather than more complex. 

### Added

- The actual RFC 2119 definitions to the Standard, and a statement of caution about the use of imperatives in that document. The definitions to terms MUST and MUST NOT are excluded in keeping with the decision to only use the terms SHALL or SHALL NOT when referring to actions in the Standard that mandate compliance.

- A note restricting the use of imperatives to instances where they are actually required for interoperation or to limit behavior which has potential for causing harm.

- A qualifying note distinguishing between signing keys and secret keys used to decrypt images. The former are required to be unique to the ECU to avoid replay attacks, but the latter need not be unique.

- A recommendation that filenames of images SHOULD be encoded to prevent a path traversal on the client system, either by using URL encoding or by limiting the allowed character set in the filename.


### Changed

- Policy on when changes to the Standard become “official” by adding the following statement to the Standard repository, “As the Standard is a living document, updates are made in real time as needed. However, these changes will not be considered formally adopted until the release of the next minor or major version.”

- The wording used to refer to actions in the Standard that require compliance from a mix of SHALL and MUST to just SHALL. Previously, the two words were used interchangeably in the document. However, in other contexts, there are subtle differences in the meaning of these words. By consistently using just SHALL, it reduces any possible confusion.

- The stipulation in Section 5.4 that ECUs monitor the download speed of image metadata and image binaries to detect and respond to a slow retrieval attack from a SHOULD to a SHALL. 

- The stipulation in Section 5.4.3.4 that ECUs check that the length of the image matches the length listed in the metadata from a SHOULD to a SHALL.

- The description of the relationship between Primaries and Secondaries if a vehicle has multiple Primaries. It is now described this way: “If multiple such Primaries are included within a vehicle, each Primary SHOULD have a designated set of Secondaries.”

- The stipulation in Section 5.2.3.1 that a vehicle identifier be used in a situation where Targets metadata from the Director repository include no images from a SHOULD to a SHALL. The stronger compliance word is needed to prevent replay attacks.

### Removed

- All references to the Uptane Time Server. While having a secure source of time is still mandated as a requirement for compliance, we are no longer recommending the Uptane Time Server as that source. Several other time source options are discussed in the [“Setting up Uptane Repositories” section of Deployment Best Practices](https://uptane.github.io/deployment-considerations/repositories.html).


## [1.2.0] - 2021-07-16
As this is the second minor release issued in 2021, the short list of changes made to the Uptane Standard between January 8 and July 2 of this year were primarily wordsmithing corrections to improve clarity. 

### Added

- A "SHOULD" requirement to the Standard that recommends including vehicle identifiers to targets metadata in order to avoid replay attacks. The sentence "Targets metadata from the Director repository SHOULD include a vehicle identifier if there are no images included in the targets metadata" was added to Section 5.2.3.1.

- The word "unique" wherever the Standard mentions key thresholds. This is to clarify that multiple signatures from the same key do not count as a threshold. 

### Changed

- The location of the "Terminology" section. All definitions have been moved to the Glossary section of the Deployment Best Practices document.

### Removed

- The use of the phrase "secondary storage," because this usage was very unclear. Instead, the Standard now refers to secondaries with "limited storage to receive an image." 


## [1.1.0] - 2021-01-08
The changes made to the Uptane Standard since its initial release on July 31, 2019, have principally addressed issues of style, clarity, and the resolution of inconsistencies. As a result, the majority of text edits and additions seek to correct wording in the original text that could potentially be misleading.

### Added

- A style guide to impose consistency in spelling, capitalization of roles and repository names, and use of punctuation.

- A policy for how to link to the Standard or any specific portion of it. Any links to the Standard from other documents should point to the latest released version, and should  link by section name, not number, as the numbers tend to change more than the names.

- A document archive policy to add a stable copy of each version of the Standard to the repository, starting with the initial IEEE/ISTO V.1.0.0 document.

- A new entry to the list of what is "Out of scope" for the Standard: "Compromise of the packaged software, such as malware embedded in a trusted package." 

- The option to use a counter (instead of a nonce) in the ECU Version Report, and the purpose of the nonce in the step-by-step instructions for preparing this report.

- A clarification that metadata is required at manufacturing time, and a rationale for why preinstalled metadata is needed. This step enables an ECU to authenticate that a remote repository is legitimate when it first downloads metadata in the field, which can serve as a defense against rollback attacks.

- A clarification that there is no need to download all metadata from the Image repo if the Director indicates there are no new updates to install.

- A clarification about the manner in which we identify images by their hash. It specifies that if the Primary has received multiple hashes for a given image binary via the Targets role, then it SHALL verify every hash for this image. This step is to be performed even if the image is identified by a single hash as part of its filename.

- A clarification that full verification MUST be performed by Primary ECUs and MAY be performed by Secondary ECUs.

- A missing reference to the Standard pointing to the Time Server description in *Uptane Deployment Best Practices.*

### Changed

- The name of our deployment considerations document. It is now *Uptane Deployment Best Practices* to better reflect naming conventions within the community.

- The way steps are referenced in the ECU process for verifying the latest downloaded metadata.
 
- Several numbering references in the full verification process, and "Step 0" in the procedure for checking Root metadata.

- Moved a Targets metadata check for unrecognized ECU IDs to a more logical place in the series of checks.

- Resolved an inconsistency in how checking hashes of images is discussed.

- Aligned naming of example hashes with [NIST policy](https://csrc.nist.gov/projects/hash-functions/nist-policy-on-hash-functions) on hash functions. This change was also made to demonstrate that Uptane is not tied to any particular set of algorithms.

- Specified that the ECU SHOULD check that the length of the image matches the length listed in the metadata in the procedure for checking hashes.

- Modified wording to make verifying a time message optional if the ECU does not have the capacity to do so.

- Replaced phrases that were incorrect, or could be mistaken for another object or function. These included the phrases *target metadata,* *image metadata,* *ECU version manifest,* and *Uptane Standards* (plural, instead of singular).
 
- Corrected additional capitalization and punctuation usages for consistency, including imposing the consistent use of the Oxford comma in a series of items within a sentence, and placing a comma after e.g. and i.e.
 
- Corrected other stylistic/formatting issues that interfered with clarity, such as extraneous commas and use of whitespace.

- Replaced phrases that were incorrect, or could be mistaken for another object or function. These included the phrases *target metadata,* *image metadata,* *ECU version manifest,* and *Uptane Standards* (plural, instead of singular).

- Switched a MAY to a SHOULD  in the statement “Full verification MUST be performed by Primary ECUs and SHOULD be performed by Secondary ECUs,” to be consistent with references elsewhere in the Standard. 

- Credited the document’s authorship to the Uptane Community, and changed the organization name from the Uptane Alliance to Joint Development Foundation Projects, LLC, Uptane Series.

### Removed
 
- Removed words from the opening definition section that are not used in the Standard.

- Removed references to TAP 5 in three places in the Standard. TAP 5 has been more or less replaced by TAP 13, but the latter has not yet been approved. 
 
