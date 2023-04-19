---
layout: default
css_id: glossary
---

# Glossary

### Conformance terminology

The keywords REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL in this document are to be interpreted as described in [RFC2119](https://uptane.github.io/papers/uptane-standard.2.0.0.html#RFC2119). Given the importance of interpreting these terms correctly, we present these definitions here. Note that when referring to actions in the Standard that mandate compliance, the word SHALL will be used, rather than the word MUST. 

*SHALL* This word or the term "REQUIRED" mean that the definition is an absolute requirement of the specification.

*SHALL NOT* This phrase means that the definition is an absolute prohibition of the specification.

*SHOULD* This word or the adjective "RECOMMENDED" mean that, in particular circumstances, there may exist valid reasons to ignore a particular item, but the full implications must be understood and carefully weighed before choosing a different course.

*SHOULD NOT* This phrase or the phrase "NOT RECOMMENDED" mean that there may exist valid reasons in particular circumstances when the particular behavior is acceptable or even useful, but the full implications should be understood and the case carefully weighed before implementing any behavior described with this label.

*MAY* This word, or the adjective "OPTIONAL," mean that an item is truly optional and may or may not be implemented at the discretion of the adopter.

In order to be considered Uptane-conformant, an implementation SHALL follow all of these rules as specified in the document.

Note that, following the recommendations of [RFC2119](https://uptane.github.io/papers/uptane-standard.2.0.0.html#RFC2119), imperatives of the type defined here will be used only when essential for security.

### Terminology

*Bundle:* A set of images released by the repository that is meant to be installed by one or more ECUs on a vehicle during the same update cycle.

*Bus:* An internal communications network that interconnects components within a vehicle. A vehicle can have a number of buses that will vary in terms of power, speed, and resources.

*Defense-in-Depth:* As defined by [US NIST IR8183](https://nvlpubs.nist.gov/nistpubs/ir/2017/NIST.IR.8183.pdf) "The application of multiple countermeasures in a layered or stepwise manner to achieve security objectives. The methodology involves layering heterogeneous security technologies in the common attack vectors to ensure that attacks missed by one technology are caught by another." Defense-in-Depth is part of the rationale for using Uptane in conjunction with some form of transport security, as discussed in the [Customizing Uptane](https://uptane.github.io/deployment-considerations/customizations.html) section of Deployment Best Practices.

*ECU Identifier:* An attribute used to identify a specific ECU (e.g., a unique serial number). This identifier SHOULD be globally unique as per the stipulations of [IEEE Standard 802.1AR](https://1.ieee802.org/security/802-1ar/). 

*ECU Version Manifest:* Metadata which details the software version currently installed on the ECU.

*Hardware Identifier:* An attribute used to identify a model of an ECU.

*Image:* File containing software for an ECU to install. May contain a binary image to flash, installation instructions, and other necessary information for the ECU to properly apply the update. Each ECU typically holds only one image, although this may vary in some cases.

*Metadata:* Information describing the characteristics of data. This could include both structural metadata that describes data structures (e.g., data format, syntax, and semantics), and descriptive metadata that details data content (e.g., information security labels). As used in Uptane, metadata can be described as information associated with a role or an image that contains the characteristics or parameters thereof (e.g., cryptographic material parameters, filenames, and versions).

*Primary/Secondary ECUs:* Terms used to describe the control units within a ground vehicle. A Primary ECU downloads and verifies update images and metadata for itself and for Secondary ECUs, and distributes images and metadata to Secondaries. Thus, it requires extra storage space and a means to download images and metadata. Secondary ECUs receive their update images and metadata from the Primary, and only need to verify and install their own metadata and images.

*POUF:* A document that contains the protocol, operations, usage, and formats (POUF) of a specific Uptane implementation. The POUF contains decisions about SHOULDs and MAYs in an implementation, as well as descriptions of data binding formats. POUFs MAY be used to create compatible Uptane implementations.

*Repository:* A server containing metadata about images, and sometimes the images themselves. Other data may be stored on the repository to be accessed by ECUs during the update process.

*Root of Trust:* Component that needs to always behave in the expected manner because its misbehavior cannot be detected. (Source: https://www.iso.org/standard/66510.html from ISO/IEC 11889-1:2015 Information technology — Trusted platform module library — Part 1: Architecture)

*Suppliers:* Independent companies to which vehicle manufacturers may outsource the production of ECUs. Tier-1 suppliers directly serve the manufacturers. Tier-2 suppliers are those that perform outsourced work for Tier-1 suppliers.

*Trust:* A characteristic of an entity that indicates its ability to perform
certain functions or services correctly, fairly and
impartially, along with assurance that the entity and its identifier are
genuine. (Source: https://csrc.nist.gov/glossary from US NIST SP800-152 Profile for U.S. Federal Cryptographic Key
Management Systems)

*Trustworthy:* Data or files stored electronically in an accurate, reliable and usable/readable manner,
ensuring integrity over time (Source: https://csrc.nist.gov/glossary from ISO TR 15801:2009 Document management — Information stored
electronically — Recommendations for trustworthiness and reliability)

*Trustworthiness:* The attribute of a person or enterprise that provides confidence to others
of the qualifications, capabilities, and
reliability of that entity to perform specific tasks and fulfill assigned
responsibilities. (Source: https://csrc.nist.gov/glossary from NIST SP800-53rev5 Security and Privacy Controls for Information
Systems and Organizations)

*Vehicle Version Manifest:* A compilation of all ECU version reports on a vehicle. It serves as a master list of all images currently running on all ECUs in the vehicle.

### Uptane role terminology

*Delegation:* A process by which the responsibility of signing metadata about images is assigned to another party. 

*Role:* A party (human or machine) responsible for signing a certain type of metadata. The role controls keys and is responsible for signing metadata entrusted to it with these keys. The roles mechanism of Uptane allows the system to distribute signing responsibilities so that the compromise of one key does not necessarily impact the security of the entire system.

* *Root role:* Signs metadata that distributes and revokes public keys used to verify the Root, Timestamp, Snapshot, and Targets role metadata.

* *Snapshot role:* Signs metadata that indicates which images the repository has released at the same time.

* *Targets role:* Signs metadata used to verify the image, such as cryptographic hashes and file size.

* *Timestamp role:* Signs metadata that indicates if there are any new metadata or images on the repository.

<!---
Copyright 2022 Joint Development Foundation Projects, LLC, Uptane Series

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
