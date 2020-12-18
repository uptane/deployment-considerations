---
layout: default
css_id: changelog
---


The changes made to the Uptane Standard since its initial release on July 31, 2019, have principally addressed issues of style, clarity, and the resolution of inconsistencies. As a result, the majority of text edits and additions seek to correct wording in the original text that could potentially be misleading.

The following is a brief summary of those edits:

- Established a style guide to impose consistency in spelling, capitalization of roles and repository names, and use of punctuation.

- Specified a policy for linking to the Standard or any specific portion of it. Any links to the Standard from other documents should point to the latest released version, and should  link by section name, not number, as the numbers tend to change more than the names.

- Established a document archive policy to add a stable copy of each version of the Standard to the repository, starting with the initial IEEE/ISTO V.1.0.0 document.

- Added “Compromise of the packaged software, such as malware embedded in a trusted package” to the list of what is "Out of scope" for the Standard.

- Corrected/changed several numbering references in the full verification process and “Step 0” in the procedure for checking Root metadata.

- Presented the option to use a counter (instead of a nonce) in the ECU Version Report, and specified the purpose of the nonce in the step-by-step instructions for preparing this report.

- Specified that the Director SHOULD check that the nonce or counter in each ECU Version Report has not been used before to prevent a replay of the ECU Version Report. If the nonce or counter is reused the Director SHOULD drop the request.

- Changed the way steps were referenced in the ECU process for verifying the latest downloaded metadata.

- Clarified that there is no need to download all metadata from the Image repo if the Director indicates there are no new updates to install.

- Clarified that metadata is required at manufacturing time, and presented a rationale for why preinstalled metadata is needed.  This step enables an ECU to authenticate that a remote repository is legitimate when it first downloads metadata in the field, which can serve as a defense against rollback attacks.

- Moved a Targets metadata check for unrecognized ECU IDs to a more logical place in the series of checks.

- Resolved an  inconsistency in how checking hashes of images is discussed.

- Clarified the manner in which we identify images by their hash to specify that if the Primary has received multiple hashes for a given image binary via the Targets role, then it SHALL verify every hash for this image. This step is to be performed even if the image is identified by a single hash as part of its filename.

- Improved naming of example hashes to align with NIST policy (https://csrc.nist.gov/projects/hash-functions/nist-policy-on-hash-functions) on hash functions. This change was also made to demonstrate that Uptane is not tied to any particular set of algorithms.

- Clarified that full verification MUST be performed by Primary ECUs and MAY be performed by Secondary ECUs.

- Specified in the procedure for checking hashes that the ECU SHOULD check that the length of the image matches the length listed in the metadata.

- Modified wording to make verifying a time message optional if the ECU does not have the capacity to verify a time message.

 
- Formally changed the name of our deployment considerations document  to *Uptane Deployment Best Practices.* This was done to better reflect naming conventions within the community.
 
- Corrected additional capitalization and punctuation usages for consistency, including imposing the consistent use of the Oxford comma in a series of items within a sentence, and placing a comma after e.g. and i.e.
 
- Corrected other stylistic/formatting issues that interfered with clarity, such as extraneous commas and use of whitespace.
 
- Removed the use of the phrase “best practices” when not referring to the *Uptane Deployment Best Practices.*
 
- Added a missing reference to the Standard pointing to the Time Server description in *Uptane Deployment Best Practices.*
 
- Changed a MAY to a SHOULD  in the statement “Full verification MUST be performed by Primary ECUs and SHOULD be performed by Secondary ECUs” to be consistent with references elsewhere in the Standard.
 
- Removed or changed phrases that were incorrect or could be mistaken for another object or function. These included the phrases *target metadata,* *image metadata,* *ECU version manifest,* and *Uptane Standards* (plural instead of singular).
 
- Removed words from the opening definition section that are not used in the Standard.
 
- Changed the document’s author credit from the Uptane Alliance Community to the Uptane Community, and the organization from the Uptane Alliance to Joint Development Foundation Projects, LLC, Uptane Series.

- Removed references to TAP 5 in three places in the Standard. TAP 5 has been more or less replaced by TAP 13, but the latter has not yet been approved. 
