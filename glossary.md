---
layout: default
css_id: glossary
---

# Glossary

### Conformance terminology
The keywords MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL in this document are to be interpreted as described in {{RFC2119}}.

In order to be considered Uptane-compliant, an implementation MUST follow all of these rules as specified in the document.

### Terminology

*Bundle:* A set of images released by the repository that is meant to be installed by one or more ECUs on a vehicle during the same update cycle.

*Bus:* An internal communications network that interconnects components within a vehicle. A vehicle can have a number of buses that will vary in terms of power, speed, and resources.

*ECU Identifier:* An attribute used to identify a specific ECU (e.g., a unique serial number).

*ECU Version Manifest:* Metadata which details the software version currently installed on the ECU.

*Hardware Identifier:* An attribute used to identify a model of an ECU.

*Image:* File containing software for an ECU to install. May contain a binary image to flash, installation instructions, and other necessary information for the ECU to properly apply the update. Each ECU typically holds only one image, although this may vary in some cases.

*Metadata:* Information describing the characteristics of data. This could include structural metadata that describes data structures (e.g., data format, syntax, and semantics) and descriptive metadata that details data content (e.g., information security labels). As used in Uptane, metadata can be described as information associated with a role or an image that contains the characteristics or parameters thereof (e.g., cryptographic material parameters, filenames, and versions.)

*Primary/Secondary ECUs:* Terms used to describe the control units within a ground vehicle. A Primary ECU downloads and verifies update images and metadata for itself and for Secondary ECUs, and distributes images and metadata to Secondaries. Thus, it requires extra storage space and a means to download images and metadata. Secondary ECUs receive their update images and metadata from the Primary, and only need to verify and install their own metadata and images.

*POUF:* A document that contains the protocol, operations, usage, and formats (POUF) of a specific Uptane implementation. The POUF contains decisions about SHOULDs and MAYs in an implementation, as well as descriptions of data binding formats. POUFs MAY be used to create compatible Uptane implementations.

*Repository:* A server containing metadata about images, and sometimes the images themselves. Other data may be stored on the repository to be accessed by ECUs during the update process.

*Suppliers:* Independent companies to which vehicle manufacturers may outsource the production of ECUs. Tier-1 suppliers directly serve the manufacturers. Tier-2 suppliers are those that perform outsourced work for Tier-1 suppliers.

*Vehicle Version Manifest:* A compilation of all ECU version reports on a vehicle. It serves as a master list of all images currently running on all ECUs in the vehicle.

### Uptane role terminology

These terms are defined in greater detail in {{roles}}.

*Delegation:* A process by which the responsibility of signing metadata about images is assigned to another party. 

*Role:* A party (human or machine) responsible for signing a certain type of metadata. The role controls keys and is responsible for signing metadata entrusted to it with these keys. The roles mechanism of Uptane allows the system to distribute signing responsibilities so that the compromise of one key does not necessarily impact the security of the entire system.

* *Root role:* Signs metadata that distributes and revokes public keys used to verify the Root, Timestamp, Snapshot, and Targets role metadata.

* *Snapshot role:* Signs metadata that indicates which images the repository has released at the same time.

* *Targets role:* Signs metadata used to verify the image, such as cryptographic hashes and file size.

* *Timestamp role:* Signs metadata that indicates if there are any new metadata or images on the repository.

### Acronyms and abbreviations

*CDN:* Content Delivery Network

*ECUs:* Electronic Control Units, the computing units on a vehicle

*LIN Bus:* Local Interconnect Bus

*OBD:* On-board diagnostics

*SOTA:* Software Updates Over-the-Air

*UDS:* Unified Diagnostic Services

*VIN:* Vehicle Identification Number

