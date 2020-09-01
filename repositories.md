---
layout: default
css_id: repositories
---

# Setting up Uptane repositories

This page outlines recommended procedures for the one-time operations that an OEM and its suppliers SHOULD perform when they set up Uptane for the first time. In particular, they SHOULD correctly configure the Director and Image repositories, and, if used, the Time Server, so that the impact of a repository/server compromise is limited to as few ECUs as possible.

## Secure Source of Time

Without access to a secure source of time, ECUs may be prevented from receiving the most recent updates. If the ECU's time is set too far ahead, it will detect that the current valid metadata is expired and thus be unable to perform an update. If the ECU's time is set too far behind, an attacker can freeze or replay old metadata to the ECU. (ECUs in Uptane will not accept an earlier time than what has been seen before and signed with the same key.)

If an ECU does not have a secure clock, we recommend the use of a Time Server for time attestations. This section describes how a Time Server can be used in an Uptane implementation.

### Time server

As the name suggests, a Time Server is a dedicated server that is responsible for providing a secure source of current time to ECUs that would not otherwise have access to this information. It informs ECUs in a cryptographically secure way through signed records and an exchange of tokens. The Time Server receives a list of tokens from vehicles, and returns back a list of signed records containing every token from the originally received list and at least one instance of the current time.

If the Time Server is used, it is CONDITIONALLY REQUIRED to conform to the following requirements:

* When the Time Server receives a sequence of tokens from a vehicle, it will provide one or more signed responses, containing the time along with these tokens. It MAY produce either one signed time attestation containing the current time and all tokens, or multiple time attestations each containing the current time and one or more tokens. All tokens should be included in the response.

* The Time Server will expose a public interface for communicating with Primaries. This communication MAY occur over FTP, FTPS, SFTP, HTTP, HTTPS, or any other transport control the implementor may choose.

* The Time Server's key is rotated in the same manner as other roles' keys by listing the new key in the Director's Root metadata. It is also listed in the custom field of the Director repository's Targets metadata (for partial verification Secondaries).

#### Changes to the Director repository
If a Time Server is in use, a representation of its public key is CONDITIONALLY REQUIRED in Director repository Root metadata.

If a Time Server is implemented AND partial verification Secondaries are used, the following metadata is CONDITIONALLY REQUIRED in the Director repository's Targets metadata:

* A representation of the public key(s) for the Time Server, similar to the representation of public keys in Root metadata.

Listing the public key of the Time Server in Director Targets metadata is necessary to allow partial verification Secondaries to perform Time Server key rotation.

#### Changes to a Primary

If the Time Server is implemented, the Primary is CONDITIONALLY REQUIRED to use the following procedure to verify the time. This procedure occurs after the vehicle version manifest is sent and will fulfill the ["Download and check current time"](https://uptane.github.io/papers/ieee-isto-6100.1.0.0.uptane-standard.html#check_time_primary) step of the Uptane Standard.

1. Gather the tokens from each Secondary ECU's version report.
2. Send the list of tokens to the Time Server to fetch the current time. The Time Server responds, as described in the [Time Server section](#time-server), by providing a cryptographic attestation of the last known time.
3. If the Time Server's response meets the criteria below, update the Primary ECU's clock and retain the Time Server's response for distribution to Secondary ECUs. If it fails to meet this criteria, discard the response and continue the procedure without an updated time.  The criteria for checking the Time Server's response are:
  - The signature over the Time Server's response is valid.
  - All the tokens provided to the Time Server are included in the response.
  - The time in the Time Server's response is later than the last time verified in this manner.

#### ECU Version Report

The ECU version report from each Secondary will contain a token to be sent to the Time Server in whatever manner the implementer chooses.  For example, the payload of the ECU version report sent from the Primary to the Director MAY contain the tokens sent to the Time Server. In this case, if any token is removed or changed, the signature will not match.  To detect a replay attack, each token SHOULD be unique per ECU. As we expect that these updates will be relatively infrequent (e.g., due to a limited number of write cycles), there will be a sufficient number of tokens to make this possible.  

#### Changes to all ECUs

At build time, ECUs will receive an attestation of the current time as downloaded from the Time Server.

As the first step to verifying metadata, described in the Standard for both the [Primary](https://uptane.github.io/papers/ieee-isto-6100.1.0.0.uptane-standard.html#check_time_primary) and [Secondaries](https://uptane.github.io/papers/ieee-isto-6100.1.0.0.uptane-standard.html#verify_time), the ECU SHOULD load and verify the most recent time from the Time Server using the following procedure:

1. Verify that the signatures on the downloaded time are valid.
2. Verify that the list of tokens in the downloaded time includes the token that the ECU sent in its version report.
3. Verify that the time downloaded is greater than the previous time.

If all three steps are completed without error, the ECU is CONDITIONALLY REQUIRED to overwrite its current attested time with the time it has just downloaded, and to generate a new token for the next request to the Time Server.

If any check fails, the ECU is CONDITIONALLY REQUIRED to NOT overwrite its current attested time, to jump to the last step ([Create and Send Version Report](https://uptane.github.io/uptane-standard/uptane-standard.html#create_version_report)), and to report the error.

#### Changes to check Root metadata

In order to prevent a new Time Server from accidentally causing a rollback warning, the clock will be reset when switching to a new Time Server. To do this, check the Time Server key after updating to the most recent Root metadata file. If the Time Server key is listed in the Root metadata and has been rotated, reset the clock used to set the expiration of metadata to a minimal value (e.g. zero, or any time that is guaranteed to not be in the future based on other evidence).  It will be updated in the next cycle.

#### Changes to partial verification Secondaries

As partial verification Secondaries only check the Targets metadata from the Director repository, the Time Server key on these ECUs will be checked when verifying the Targets metadata. To do this, check the Time Server key after verifying the most recent Targets metadata file. If the Time Server key is listed in the Targets metadata and has been rotated, reset the clock used to determine the expiration of metadata to a minimal value as described above.

## What suppliers should do

<img align="center" src="assets/images/repo_1_supplier_sign.png" width="500" style="margin: 0px 20px"/>

**Figure 1.** *Diagram showing supplier signing arrangements. Suppliers are free to ask the OEM to sign images on its behalf (supplier A), or can sign them itself (supplier B). In the latter case, it MAY also delegate some or all of this responsibility to others (supplier C).*

Either the OEM or a tier-1 supplier SHOULD sign for images for any ECUs produced by that supplier, so unsigned images are never installed. This provides security against arbitrary software attacks. An OEM will decide whether or not a tier-1 supplier SHOULD sign its own images. Otherwise, the OEM will sign images on behalf of the supplier, and the supplier SHOULD only deliver update images to the OEM as outlined under the [Normal Operations](https://uptane.github.io/deployment-considerations/normal_operation.html) guidelines. If the supplier signs its own images, it MUST first set up roles and metadata using the following steps:

1. Generate a number of offline keys used to sign its metadata. In order to provide compromise-resilience, these keys SHOULD NOT be accessible from the Image repository. The supplier SHOULD take great care to secure these keys, so a compromise affects only some, but not all, of its ECUs. The supplier SHOULD use the threshold number of keys chosen by the OEM.
2. Optionally, delegate images to members of its organization (such as its developers), or to tier-2 suppliers (who MAY further delegate to tier-3 suppliers). Delegatees SHOULD recursively follow these same steps.
3. Set an expiration timestamp on its metadata using a duration prescribed by the OEM.
4. Register its public keys with the OEM using some out-of-band mechanism (e.g., telephone calls, or certified mail).
5. Sign its metadata using the digital signature scheme chosen by the OEM.
6. Send all metadata, including delegations, and associated images to the OEM

A tier-1 supplier and its delegatees MAY use the [Uptane repository and supplier tools](https://github.com/uptane/uptane) to produce these signed metadata.

## What the OEM should do

The OEM sets up and configures the Director and Image repositories. To host these backend services, the OEM MAY use its own private infrastructure, or cloud computing.

### Director Repository

*Note that all information about setting up signing keys for this repository can be found on the [Key Management](https://uptane.github.io/deployment-considerations/key_management.html) page of this website*

In order to provide on-demand customization of vehicles, the OEM MUST also build the Director repository, following the guidance in the [Uptane Standard](https://uptane.github.io/papers/ieee-isto-6100.1.0.0.uptane-standard.html#director_repository). In addition, an OEM must keep in mind the following factors. Unlike the Image repository, the Director repository: (1) is managed by automated processes, (2) uses online keys to sign Targets metadata, (3) does not delegate images, (4) generally provides different metadata to different Primaries, (5) MAY encrypt images per ECU, and (6) produces new metadata on every request by Primaries.

**Steps to initialize the repository**

In order to initialize the repository, an OEM SHOULD perform the following steps:

1. Set up the storage mechanism according to the directions for the chosen protocol. For example, the OEM might need to set up a ZFS filesystem.
2. Set up the transport protocol, following the details of the chosen systems. For example, the OEM may need to set up an HTTP server with SSL/TLS enabled.
3. Set up the private and public APIs to interact over the chosen transport protocol.
4. Set up the Timestamp, Snapshot, Root, and Targets roles.
5. Copy all unencrypted images from the Image repository.
6. Initialize the inventory database with the information necessary for the Director repository to perform dependency resolution, or encrypt images per ECU. This information includes: (1) metadata about all available images for all ECUs on all vehicles, (2) dependencies and conflicts between images, and (3) ECU keys.
7. Set up and run the automated process that communicates with Primaries.

The automated process MAY use the repository tools from our [Reference Implementation](https://github.com/uptane/uptane) to generate new metadata.

#### Roles

<img align="center" src="assets/images/repo_2_roleson_director.png" width="500" style="margin: 0px 20px"/>

**Figure 2.** *A proposed configuration of roles on the Director repository.*

Unlike the Image repository, the Director repository does not delegate images. Therefore, the Director repository SHOULD contain only the Root, Timestamp, Snapshot, and Targets roles, as illustrated in Figure 2. In the rest of this section, we will discuss how metadata for each of these roles is produced.

#### Private API to update images and the inventory database

An OEM SHOULD define a private API for the Director repository, so that it is able to: (1) upload images, and (2) update the inventory database. This API is private in the sense that only the OEM should be able to perform these actions. 

This API SHOULD require authentication, so that each user is allowed to access only certain information. The OEM is free to use any authentication method, as long as it is suitably strong, such as [client certificates](https://blogs.msdn.microsoft.com/kaushal/2012/02/17/client-certificates-vs-server-certificates/), or [two-factor authentication](https://en.wikipedia.org/wiki/Multi-factor_authentication), such as a username coupled with a password, or an API key encrypted over TLS,.

In order to allow automated processes on the Director repository to perform their respective functions, without also allowing any attackers who might compromise the repository to tamper with the inventory database, it is strongly RECOMMENDED that these processes should have some boundaries. That is, the automated processes SHOULD be able to read any record in the database and write new records, but SHOULD NOT be able to update or delete existing records.

#### Public API to send updates

<img align="center" src="assets/images/repo_4_primarytodirector.png" width="500" style="margin: 0px 20px"/>

**Figure 3.** *How Primaries would interact with the Director repository.*

An OEM SHOULD define a public API to the Director repository so that it is able to send updates to vehicles. This API can be designed to the wishes of the OEM, and can use either a push or pull model to send updates updates to Primaries. The difference between the models lies in whether or not a running vehicle can be told to immediately download an update (via a push), or can wait until a pull occurs.

Either way, the OEM can control how often updates are released to vehicles. In the push model, the OEM can send an update to a vehicle whenever it likes, as long as the vehicle is online. In the pull model, the OEM can configure the frequency at which Primaries pull updates. In most realistic cases, there will be little practical difference between the two models.

There is also no significant difference between these methods when it comes to resistance to denial-of-service (DoS) attacks or flash crowds. In the push model, a vehicle can control how often updates are pushed to it, so that vehicles can withstand DoS attacks, even if the repository has been compromised. In the pull model, the repository can similarly stipulate when vehicles SHOULD download updates, and how often.

Regardless of what model is used to send updates, as illustrated in Figure 4, the API SHOULD allow a Primary to:
* send a vehicle version manifest (step 1)
* receive a link to a Timestamp metadata file in return (step 4)
* download associated files (step 5).

The API MAY require authentication, depending on the OEM’s requirements.

#### Sending an update

Sending an update from the Director repository to a Primary requires the following five steps, as shown in Figure 3.

1. The Primary sends its latest vehicle version manifest to the Director repository via an automated process.
2. The automated process performs a dependency resolution. It reads associated information about this vehicle, such as ECU identifiers and keys, from the inventory database. It checks that the signatures on the manifest are correct, and adds the manifest to the inventory database. Then, using the given manifest, it computes which images SHOULD be installed next by these ECUs. It SHOULD record the results of this computation on the inventory database so there is a record of what was chosen for installation. If there is an error at any point of this step, due to incorrect signatures, or anything unusual about the set of updates installed on the vehicle, then the Director repository SHOULD also record it, so the OEM can be alerted to a potential risk. Repository administrators MAY then take manual steps to correct the problem, such as instructing the vehicle owner to visit the nearest dealership.
3. Using the results of the dependency resolution, the automated process signs fresh Timestamp, Snapshot, and Targets metadata about the images that SHOULD be installed next by these ECUs. Optionally, if the OEM requires it, it MAY encrypt images per ECU, and write them to its storage mechanism. If there are no images to be installed or updated, then the Targets metadata SHOULD contain an empty set of targets.
4. The automated process returns a link to the Timestamp metadata file to the Primary.
5. The Primary downloads metadata and images using the link to this Timestamp metadata file.

Since the automated process is continually producing new metadata files (and, possibly, encrypted images), these files SHOULD be deleted as soon as Primaries have consumed them, so that storage space can be reclaimed. This MAY be done by simply tracking whether Primaries have successfully downloaded these files within a reasonable amount of time.

### Image repository

*Note that all information about setting up signing keys for this repository can be found on the [Key Management](https://uptane.github.io/deployment-considerations/key_management.html) page of this website*

Finally, in order to provide compromise-resilience, the OEM will build the [Image repository](https://uptane.github.io/papers/ieee-isto-6100.1.0.0.uptane-standard.html#image-repository) following the guidance in the Uptane Standard. The Image repository differs from the Director repository in a number of ways. First, it is managed by human administrators who use offline keys to sign targets metadata. It also MAY delegate images to suppliers, and provides the same metadata to all Primaries. Lastly, it does not encrypt images per ECU, and updates its metadata and images relatively infrequently (e.g., every two weeks, or monthly).

**Steps to initialize the repository**

In order to initialize the repository, an OEM SHOULD perform the following steps. Note that, as with the Director repository, all users are expected to follow-up basic set up instructions, as well as
the specific set up instructions governed by the users' choices of storage mechanisms and protocols.
1. Set up the storage mechanism.
2. Set up the transport protocol.
3. Set up the private and public APIs to interact over the chosen transport protocol.
4. Set up the Timestamp, Snapshot, Root, and Targets roles.
5. Sign delegations from the Targets role to all tier-1 supplier roles. The public keys of tier-1 suppliers SHOULD be verified using some out-of-band mechanism (e.g., telephone calls, certified mail), so that the OEM can double-check their authenticity and integrity.
6. Upload metadata and images from all delegated Targets roles (including tier-1 suppliers). Verify the metadata and images, and add them to the storage mechanism.

An OEM and its suppliers MAY use the repository and supplier tools from the [Reference Implementation](https://github.com/uptane/uptane) to produce new metadata.

#### Roles

<img align="center" src="assets/images/repo_5_roles_on_image.png" width="500" style="margin: 0px 20px"/>

**Figure 4.** *A proposed configuration of roles on the Image repository.*

Using delegations allows the OEM to: (1) control which roles sign for which images, (2) control precisely which Targets metadata vehicles need to download, and (3) distribute, revoke, and replace public keys used to verify Targets metadata, and hence, images. In order to set up delegations, an OEM and its suppliers MAY use the configuration of roles illustrated in Figure 4. There are two important points.

* The OEM maintains the Root, Timestamp, Snapshot, and Targets roles, with the Targets role delegating images to their respective tier-1 suppliers.
* There SHOULD be a delegated Targets role for every tier-1 supplier, so that the OEM can:
  * limit the impact of a key compromise
  * precisely control which Targets metadata vehicles need to download.
  
The metadata for each tier-1 supplier MAY be signed by the OEM (e.g., supplier A), or the supplier itself (e.g., suppliers B and C). In turn, a tier-1 supplier MAY delegate images to members of its organization, such as supplier C, who has delegated a subset of its images to one of its developers, or its tier-2 suppliers who MAY delegate further to tier-3 suppliers.

Every delegation SHOULD be prefixed with the unique name of a tier-1 supplier, so that the filenames of images do not conflict with each other. Other than this constraint, a tier-1 supplier is free to name its images however it likes. For example, it MAY use the convention “supplier-X-ECU-Y-version-Z.img” to denote an image produced by supplier X, for ECU model Y, and with a version number Z.

#### Public API to download files

An OEM SHOULD define a public API for Primaries to use when downloading metadata and images to the Image repository. This API can be defined however the OEM wishes.

Depending on the OEM's requirements, this API MAY require authentication before Primaries are allowed to download updates.  Such a choice affects only how certain the OEM can be that it is communicating with authentic Primaries, and not how resilient ECUs are to a repository compromise. The OEM is free to use any authentication method.

#### Using images from multiple locations

When implementing Uptane, it is often the case that existing software may come from several different locations. It may be tempting to assume that this means that the equivalent Uptane implementation will require multiple different image repositories. However, this is rarely actually necessary, and using multiple image repositories (implemented via [repository mapping metadata as described in TAP-4](https://github.com/theupdateframework/taps/blob/master/tap4.md)) represents a significantly larger effort.

In almost all cases, it is preferable to have a single image repository containing all of the Uptane metadata, and redirect clients to download the actual images from other locations. This can be implemented via an API on the image repository, or via a custom field in the Targets metadata directing the clients to one or more alternate URLs where the images are available.

The API solution could be as simple as an HTTP 3xx redirect to the appropriate download location, for example. More complex schemes, e.g. cases where existing legacy repositories have a custom authentication scheme, can usually be implemented by adding custom metadata. See the [related section of the standard](https://uptane.github.io/uptane-standard/uptane-standard.html#custom-metadata-about-images) for more information on how custom metadata can be added.

## Specifying wireline formats

In setting up the Uptane program, an implementer will need to specify how information, such as metadata files, and vehicle version manifests, should be encoded. As a guiding principle of the Uptane framework is to give each implementer as much design flexibility as possible, the Uptane Standard does not specify particular data binding formats. Instead, OEMs and suppliers can continue to use the protocols and formats of existing update systems, or they can select formats that best  ensure interoperability with other essential technologies. 

To facilitate coordination between implementations, an Uptane adopter can choose to write a POUF, an added layer to the Standard in which an implementer can specify choices of Protocols, Operations, Usage and Formats. A POUF provides an easy way for an implementer to specify the elements that can ensure interoperability. It can also be customized for the special needs of fleet owners in a particular industry, such as taxis, car sharing networks, police forces, or the military.

Information on writing a POUF can be found on the POUF [Purpose and Guidelines](https://uptane.github.io/pouf.html) page on this website. A sample POUF, written for the [Uptane Reference Implementation](https://uptane.github.io/reference_pouf.html) offers sample metadata written in [ASN.1/DER](https://github.com/uptane/uptane.github.io/blob/master/reference_pouf.md#file-formats).
