---
layout: default
css_id: repositories
---

# Setting up Uptane repositories

This page outlines recommended procedures for the one-time operations that an OEM and its suppliers SHOULD perform when they set up Uptane for the first time. In particular, they SHOULD correctly configure the director and image repositories, as well as the time server, so that the impact of a repository / server compromise is limited to as few ECUs as possible.

## Secure Source of Time

Without access to a secure source of time, ECUs may be prevented from receiving the most recent updates. If the ECU's time is too high, the ECU will detect that the current valid metadata is expired and will be unable to perform an update. If the ECU's time is too low, an attacker can freeze or replay old metadata to the ECU.  (ECUs in Uptane will not accept an earlier time than what has been seen before signed with the same key.)

To prevent these issues, ECUs need access to a secure source of time. If an ECU does not have a secure clock, we recommend the use of a Time Server for time attestations. This section describes how a Time Server can be used in an Uptane implementation.

### Time server

A Time Server is a server that is responsible for the distribution of a secure source of time.

The Time Server exists to inform ECUs about the current time in a cryptographically secure way, since many ECUs in a vehicle do not have a reliable source of time. The Time Server receives a list of tokens from vehicles, and returns back a list of signed records containing every token in the original list of tokens received and at least one instance of the current time.

If the Time Server is used, it is CONDITIONALLY REQUIRED to conform to the following requirements:

* When the Time Server receives a sequence of tokens from a vehicle, it will provide one or more signed responses, containing the time along with these tokens. It MAY produce either one signed time attestation containing the current time and all tokens, or multiple time attestations each containing the current time and one or more tokens.

* The Time Server will expose a public interface allowing primaries to communicate with it. This communication MAY occur over FTP, FTPS, SFTP, HTTP, or HTTPS.

* Rotation of the The Time Server's key is performed by listing the new key in the Director's Root metadata, in the same manner as other role keys are listed, and also in the Director's Targets metadata (for partial verification secondaries).

#### Changes to the Director repository
If a Time Server is in use, a representation of the Time Server public key is CONDITIONALLY REQUIRED in Director repository root metadata.

If a Time Server is implemented AND partial-verification secondaries are used, the following metadata is CONDITIONALLY REQUIRED in the Director repository's Targets metadata:

* A representation of the public key(s) for the Time Server, similar to the representation of public keys in Root metadata.

Listing the public key of the Time Server in Director targets metadata is necessary to allow partial-verification secondaries to perform time server key rotation.

#### Changes to a Primary

If the Time Server is implemented, the primary is CONDITIONALLY REQUIRED to use the following procedure to verify the time. This procedure occurs after the vehicle version manifest is sent and will fulfill the "Download and check current time" step of the Uptane Standard.

1. Gather the tokens from each secondary ECU's version report.
2. Send the list of tokens to the Time Server to fetch the current time. The time server responds as described in [Time Server](#time_server), providing a cryptographic attestation of the last known time.
3. If the Time Server's response meets the criteria below, update the primary ECU's clock and retain the Time Server's response for distribution to secondary ECUs, otherwise discard it and proceed without an updated time.  The criteria for checking the Time Server's response are:
  - The signature over the Time Server's response is valid.
  - The tokens provided to the Time Server have been included in the response.
  - The time in the Time Server's response is later than the last time verified in this manner.

#### ECU Version Report

The payload of the ECU version report should contain the latest time downloaded from the Time Server. In addition, the report should include a token (which SHOULD be used exactly once to prevent a replay attack) for the Time Server to sign and send back.

#### Changes to all ECUs

At build time, ECUs will be provisioned with an attestation of the current time downloaded from the Time Server.

As the first step to verifying metadata, described as "Load and verify the current time or the most recent securely attested time" in the Standard, the ECU SHOULD load and verify the  most recent time from the Time Server using the following procedure:

1. Verify that the signatures on the downloaded time are valid.
2. Verify that the list of tokens in the downloaded time includes the token that the ECU sent in its previous version report.
3. Verify that the time downloaded is greater than the previous time.

If all three steps complete without error, the ECU is CONDITIONALLY REQUIRED to overwrite its current attested time with the time it has just downloaded, and generate a new token for the next request to the Time Server.

If any check fails, the ECU is CONDITIONALLY REQUIRED to NOT overwrite its current attested time, and jump to the last step ([Create and Send Version Report](https://uptane.github.io/uptane-standard/uptane-standard.html#create_version_report)), and report the error.

#### Changes to checking Root metadata

In order to prevent a new timeserver from accidentally causing a rollback warning, the clock will be reset when switching to a new timeserver. To do this, check the Timeserver key after updating to the most recent Root metadata file. If the Timeserver key is listed in the Root metadata and has been rotated, reset the clock used to determine the expiration of metadata to a minimal value (e.g. zero, or any time that is guaranteed to not be in the future based on other evidence).  It will be updated in the next cycle.

#### Changes to Partial Verification Secondaries

As partial verification secondaries only check the Targets metadata from the Director repository, the timeserver key will be checked when verifying the Targets metadata on partial verification secondaries. To do this, check the Timeserver key after verifying the most recent Targets metadata file. If the Timeserver key is listed in the Targets metadata and has been rotated, reset the clock used to determine the expiration of metadata to a minimal value as described in [Changes to checking Root metadata](#changes-to-checking-root-metadata).

## What suppliers should do

### TODO Insert Figure 1 (repo_1_supplier_sign.jpg). Insert link from third sentence to the *what suppliers should do* subsection on the Normal Operations page.

Either the OEM or a tier-1 supplier SHOULD sign for images for any ECUs produced by that supplier, so unsigned images are never installed. This provides security against arbitrary software attacks. An OEM would decide whether or not a tier-1 supplier SHOULD sign its own images. Otherwise, the OEM will sign images on behalf of the supplier, and the supplier MUST only deliver update images to the OEM as outlined on the Normal Operations page. If the  the supplier signs its own images, it MUST first set up roles and metadata using the following steps:

1. Generate a number of offline keys used to sign its metadata. In order to provide compromise-resilience, these keys MUST NOT be accessible from the image repository. The supplier MUST take great care to secure these keys, so that a key compromise affects only some, but not all, of its ECUs. The supplier MUST use the threshold number of keys chosen by the OEM.
2. Optionally, delegate images to members of its organization (such as its developers), or to tier-2 suppliers (who MAY further delegate to tier-3 suppliers). Delegatees SHOULD recursively follow these same steps.
3. Set an expiration timestamp on its metadata using a duration prescribed by the OEM.
4. Register its public keys with the OEM using some out-of-band mechanism (e.g., telephone calls, or certified mail).
5. Sign its metadata using the digital signature scheme chosen by the OEM.
6. Send all metadata, including delegations, and associated images to the OEM

A tier-1 supplier and its delegatees MAY use the [Uptane repository and supplier tools](https://github.com/uptane/uptane) to produce these signed metadata.

#### TODO Do we need the timeserver material? I did not move the subsection about the time server over because I was unsure whether we were still using this feature. I can easily add the text and diagram if it is needed.

## What the OEM should do

The OEM sets up and configures the director and image repositories. To host these backend services, the OEM MAY use its own private infrastructure, or cloud computing.

### Director Repository

#### TODO add link to the Key Management page on the website

*Note that all information about setting up signing keys for this repository can be found on the Key Management page of this website*
In order to provide on-demand customization of vehicles, the OEM MUST also build the director repository, following the guidance in the Uptane Standard. In addition, an OEM must keep in mind the following factors. Unlike the image repository, the director repository: (1) is managed by automated processes, (2) uses online keys to sign targets metadata, (3) does not delegate images, (4) generally provides different metadata to different primaries, (5) MAY encrypt images per ECU, and (6) produces new metadata on every request by primaries.

**Steps to initialize the repository**

#### TODO: Insert section links in the list below to the relevant sections in the Normal Operations list

In order to initialize the repository, an OEM SHOULD perform the following steps:

1. Set up the storage mechanism, following the directions for the choice of protocol. For example, the OEM might need to set up a ZFS filesystem.
2. Set up the transport protocol, following the details of the chosen systems. For example, the OEM may need to set up an HTTP server with SSL/TLS enabled.
3. Set up the private and public APIs to interact over the chosen transport protocol.
4. Set up the timestamp, snapshot, root, and targets roles.
5. Copy all unencrypted images from the image repository.
6. Initialize the inventory database with the information necessary for the director repository to perform dependency resolution, or encrypt images per ECU. This information includes: (1) metadata about all available images for all ECUs on all vehicles, (2) dependencies and conflicts between images, and (3) ECU keys.
7. Set up and run the automated process that communicates with primaries.

The automated process MAY use the repository tools from our [Reference Implementation] (https://github.com/uptane/uptane) to generate new metadata.

#### Roles

#### TODO: Insert Figure 3 (repo_3_roleson_director.jpg)

Unlike the image repository, the director repository does not delegate images. Therefore, the director repository SHOULD contain only the root, timestamp, snapshot, and targets roles, as illustrated in Figure 2. In the rest of this section, we will discuss how metadata for each of these roles are produced.

#### Private API to update images and the inventory database

An OEM SHOULD define a private API for the director repository, so that it is able to: (1) upload images, and (2) update the inventory database. This API is private in the sense that only the OEM should be able to perform these actions. The OEM MAY define this API as it wishes.

This API SHOULD require authentication, so that each user is allowed to access only certain information. The OEM is free to use any authentication method, as long as it is suitably strong, such as [client certificates](https://blogs.msdn.microsoft.com/kaushal/2012/02/17/client-certificates-vs-server-certificates/), or [two-factor authentication](https://en.wikipedia.org/wiki/Multi-factor_authentication), such as a username coupled with a password, or an API key encrypted over TLS,.

In order to allow automated processes on the director repository to perform their respective functions, without also allowing attackers who compromise the repository to tamper with the inventory database, it is strongly RECOMMENDED that these processes SHOULD be able to read any record in the database, and write new records, but never update or delete existing records.

#### Public API to send updates
#### TODO: Insert Figure 4 (repo_4_primarytodirector.jpg)
An OEM SHOULD define a public API to the director repository, so that it is able to send updates to vehicles. This API can be designed to the wishes of the OEM, and can use either a push or pull model to send updates updates to primaries. The difference between the models is mostly about whether a running vehicle can be told to immediately download an update (via a push), or can wait until a pull occurs.

Either way, the OEM can control how often updates are released to vehicles. In the push model, the OEM can send am update to a vehicle whenever it likes, as long as the vehicle is online. In the pull model, the OEM can configure the frequency at which primaries pull updates. In most realistic cases, there will be little practical difference between the two models.

There is no significant difference either in resistance to denial-of-service (DoS) attacks or flash crowds. In the push model, a vehicle can control how often updates are pushed to it, so that vehicles can withstand DoS attacks even if the repository has been compromised. In the pull model, the repository can similarly stipulate when vehicles SHOULD download updates, and how often, so that the repository, too, can withstand DoS attacks.

Regardless of what model is used to send updates, as illustrated in Figure 4, the API SHOULD allow a primary to:
* send a vehicle version manifest (step 1)
* receive a link to a timestamp metadata file in return (step 4)
* download associated files (step 5).

The API MAY require authentication, depending on the OEM’s requirements.

#### Sending an update
Sending an update from the director repository to a primary requires the following five steps, as shown in Figure 4.

1. The primary sends its latest vehicle version manifest to the director repository via an automated process.
2. Second, the automated process performs a dependency resolution. It reads about this vehicle from the inventory database such associated information as ECU identifiers and keys. It checks that the signatures on the manifest are correct, and adds the manifest to the inventory database. Then, using the given manifest, it computes which images SHOULD be installed next by these ECUs. It SHOULD record the results of this computation on the inventory database so there is a record of what was chosen for installation. If there is an error at any part of this step, due to incorrect signatures, or anything unusual about the set of updates installed on the vehicle being unusual, then the director repository SHOULD also record it, so the OEM can be alerted to a potential risk. Repository administrators MAY then take manual steps to correct the problem, such as instructing the vehicle owner to visit the nearest dealership.
3. Using the results of the dependency resolution, the automated process signs fresh timestamp, snapshot, and targets metadata about the images that SHOULD be installed next by these ECUs. Optionally, if the OEM requires it, it MAY encrypt images per ECU, and write them to its storage mechanism. If there are no images to be installed or updated, then the targets metadata SHOULD contain an empty set of targets.
4. Fourth, the automated process returns to the primary a link to the timestamp metadata file.
5. Fifth, the primary downloads metadata and images using the link to this timestamp metadata file.

Since the automated process is continually producing new metadata files (and, possibly, encrypted images), these files SHOULD be deleted as soon as primaries have consumed them, so that storage space can be reclaimed. This MAY be done by simply tracking whether primaries have successfully downloaded these files within a reasonable amount of time.

## Image repository
*Note that all information about setting up signing keys for this repository can be found on the Key Management page of this website*

Finally, in order to provide compromise-resilience, the OEM will build the image repository following the guidance in the Uptane Standards. The image repository differs from the director repository in a number of ways. First, it is managed by human administrators who use offline keys to sign targets metadata. It also MAY delegate images to suppliers, and provides the same metadata to all primaries. Lastly, it does not encrypt images per ECU, and updates its metadata and images relatively infrequently (e.g., every two weeks, or monthly).

**Steps to initialize the repository**

n order to initialize the repository, an OEM SHOULD perform the following steps. Note that, as with the director repository, all users are expected to follow-up basic set up instructions, as well as
the specific set up instructions governed by the users choices of storage mechanisms and protocols.
1. Set up the storage mechanism.
2. Set up the transport protocol.
3. Set up the private and public APIs to interact over the chosen transport protocol.
4. Set up the timestamp, snapshot, root, and targets roles.
5. Sign delegations from the targets role to all tier-1 supplier roles. The public keys of tier-1 suppliers SHOULD be verified using some out-of-band mechanism (e.g., telephone calls, certified mail), so that the OEM can double-check their authenticity and integrity.
6. Upload metadata and images from all delegated targets roles (including tier-1 suppliers). Verify the metadata and images, and add them to the storage mechanism.

An OEM and its suppliers MAY use the repository and supplier tools from the [Reference Implementation](https://github.com/uptane/uptane) to produce new metadata.

#### Roles
#### TODO: Insert Figure 5 (repo_5_roleson_image.jpg)

Using delegations allows the OEM to: (1) control which roles sign for which images, (2) control precisely which targets metadata vehicles need to download, and (3) distribute, revoke, and replace public keys used to verify targets metadata, and hence, images. In order to set up delegations, an OEM and its suppliers MAY use the configuration of roles illustrated in Figure 5. There are two important points.
* The OEM maintains the root, timestamp, snapshot, and targets roles, with the targets role delegating images to their respective tier-1 suppliers.
* There SHOULD be a delegated targets role for every tier-1 supplier, so that the OEM can:
  * limit the impact of a key compromise
  * precisely control precisely which targets metadata vehicles need to download.
* The metadata for each tier-1 supplier MAY be signed by the OEM (e.g., supplier A), or the supplier itself (e.g., suppliers B and C). In turn, a tier-1 supplier MAY delegate images to members of its organization, such as supplier C, who has delegated a subset of its images to one of its developers, or its tier-2 suppliers who MAY delegate further to tier-3 suppliers.

Every delegation SHOULD be prefixed with the unique name of a tier-1 supplier, so that the filenames of images do not conflict with each other. Other than this constraint, a tier-1 supplier is free to name its images however it likes. For example, it MAY use the convention “supplier-X-ECU-Y-version-Z.img” to denote an image produced by supplier X, for ECU model Y, and with a version number Z.

#### Public API to download files
An OEM MUST define a public API to the image repository for  primaries to use in order to download metadata and images. This API can be defined however the OEM wishes.

Depending on the OEM's requirements, this API MAY require authentication before primaries are allowed to download updates. The OEM is free to use any authentication method. Such a choice affects only how certain the OEM can be that it is communicating with authentic primaries, and does not affect how resilient ECUs are to a compromise of the image repository.

## Deploying/developing your own
#### TODO I could not determine what text in the original document might belong here or the two subsections below. Does new text need to be drafted?

### Director

### Image
