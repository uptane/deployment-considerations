---
layout: default
css_id: customizations
---

# Customizing Uptane

In this section, we discuss how OEMs and suppliers may customize Uptane to meet special requirements.

## Scope of an update

An image need not necessarily update all code and data on an ECU. An OEM and its suppliers MAY use an image to arbitrarily update code and data on an ECU. For example, an image MAY be used to update only some code but no data, all code and no data, no code and some data, or any other combination of the two.

Examples of code updates include the bootloader, shared libraries, and the application, which provides the actual functions of the ECU. Examples of data updates include setup or initialization data, such as engine parameters, application data, such as maps, and user data, such as an address book or system logs.

<img align="center" src="assets/images/custom_1_code_data_image.png" width="500" style="margin: 0px 20px"/>

**Figure 1.** *An example of how code and / or data may constitute an image.*


## Delta update strategies

In order to save bandwidth costs, Uptane allows an OEM to deliver updates as
delta images. A delta image update contains only the code and / or data that differs from the previous image installed by the ECU. In order to use delta images, the OEM SHOULD make the following changes.

The OEM SHOULD add two types of information to the custom targets metadata used by the Director repository: (1) the algorithm used to apply a delta image, and (2) the Targets metadata about the delta image. This is done so that ECUs know how to apply and verify the delta image. The Director repository SHOULD also be modified to produce delta images, because Uptane does not require it to compute deltas by default. The Director repository can use the vehicle version manifest and dependency resolution to determine the differences between the previous and latest images. If desired, then the Director repository MAY encrypt the delta image.

As these images are produced on demand by the Director repository, Primaries SHOULD download all delta and / or encrypted images only from that source. After full verification of metadata, Primaries SHOULD also check whether delta images match the Targets metadata from the Director repository in the same manner in which they check such metadata from the Director repository when using non-delta images.

Finally, in order to install a delta image, an ECU SHOULD take one of the actions described in Table 1, depending on whether or not the delta image has been encrypted, and if the ECU has additional storage. Note that the OEM MAY use stream ciphers in order to enable on-the-fly decryption on ECUs that do not have additional storage. In this case, the ECU would decrypt the delta image as it is downloaded, then follow the remainder of the steps in the third box below.

### TODO Write rationale for the SHOULDs throughout the section above.

### TODO Recreate and insert Table D.2a from google doc and label it as Table 1.
                                                                                                                             
### Dynamic delta updates vs. precomputed delta updates

There are two options when computing delta updates. Delta updates can be computed dynamically for each ECU during the installation process (dynamic delta updates), or possible delta images can be precomputed before installation begins (precomputed delta updates). The process for describing both types of updates appears below in the subsection on [custom installation instructions](#custom-installation-instructions-for-ecus).

Dynamic delta updates reduce the amount of data sent in each update, while allowing for fine grained control of what version is placed on each ECU.  By using the custom field of the Targets metadata, the Director can be configured to specify a particular version of software for every ECU. Dynamic delta updates allow the Director to do file granular resource tracking, which can save bandwidth by only transmitting the delta of the image.

To send dynamic delta updates, the Director would compute the delta as described
earlier in this section. The computed images would be made available to the Primary ECU.

One drawback of dynamic delta updates is that if many ECUs are updating from the same version, computing the delta of each would result in duplicate computation that could be time consuming or use up a lot of memory. A possible solution to this is to use precomputed delta updates.

To send precomputed delta updates the Director precomputes various probable diffs and makes these available as images. The Director then specifies which precomputed delta image to send to each ECU using the custom field of Targets metadata, as described below. Precomputing the delta images has the added advantage of allowing these images to be stored on the Image repository, which offers additional security against a Director compromise.

## Uptane in conjunction with other protocols

Implementers MAY use Uptane in conjunction with other protocols already being used
to send updates to the vehicle, such as in the following cases:

Implementers MAY use [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security) to encrypt the connection between
Primaries and the Image and Director repositories, as well to whatever source is used to provide the current time.

Implementers MAY use [OMA Device Management](https://en.wikipedia.org/wiki/OMA_Device_Management) (OMA-DM) to send Uptane
metadata, images, and other messages to Primaries.

Implementers MAY use [Unified Diagnostic Services](https://en.wikipedia.org/wiki/Unified_Diagnostic_Services) (UDS) to transport Uptane metadata, images, and other messages between Primaries and Secondaries.

Any system being used to transport images to ECUs needs to modified only to permit transport of Uptane metadata and other messages. Note that Uptane does not require authentication of network traffic between the Director and Image repositories and Primaries, or between Primaries and Secondaries.

However, in order for an implementation to be Uptane-compliant, no ECU can cause another ECU to install an image without performing either full or partial verification of metadata. This is done in order to prevent attackers from being able to bypass Uptane, and thus execute arbitrary software attacks. Thus, in an Uptane-compliant implementation, an ECU performs either full or partial verification of metadata and images before installing any image, regardless of how the metadata and images were transmitted to the ECU.


## Using Uptane with transport security
Uptane is designed to retain strong security guarantees even in the face of a network attacker.  This includes situations where there either is no transport security or where the transport security is compromised by an attacker.  Should this occur, Uptane may not be able to prevent an attacker from disrupting communication between the vehicle and the OEM (e.g., by jamming the signal or dropping packets).  However, malicious packages cannot be installed, mix-and-match attacks are not possible, etc.  This is similar to how a network attacker who has not compromised a key can cause a TLS connection to fail to connect or disconnect, but cannot compromise the integrity or confidentiality of the connection.

Uptane's security is orthogonal to security systems at other network layers, such as transport security, data link security, etc.  However, there are several reasons why a party may wish to use a security system at the transport layer in coordination with Uptane:

- If a security system at the transport layer is already deployed for other services or is effectively free to deploy, there is little reason not to use it.  For example, it may be beneficial to have authentication provided for all services in a vehicle by a common system.

- Regulations may require or recommend that security be provided at the transport layer. Hence, a secure transport system may be required for non-technical reasons.

- Use of transport layer security adds defense-in-depth, a security best practice, to the extent to which the transport layer security system can improve the detection, mitigation, or reporting of network disruptions.

- Security at the transport layer provides forensic proof of origin and destination (when strong mutual authentication is used).  This may be necessary for compliance to OTA update standards and various current draft regulations.

## Multiple primaries

We expect that the most common deployment configuration of Uptane on vehicles would feature one Primary per vehicle. However, we observe that there are cases where it may be useful to have multiple, active Primaries in a vehicle. For example, such a setup provides redundancy when some, but not all, primaries could fail permanently. The OEM MAY use this setup to design a failover system where one Primary takes over when another fails. If so, then the OEM SHOULD take note of the following considerations, in order to prevent safety issues.

### TODO Write rationale for the SHOULD noted above.

It is highly RECOMMENDED that in any given vehicle there be a single, active Primary. This is because using multiple, active Primaries to update Secondaries can lead to problems in consistency, especially when different Primaries try to update the same Secondaries. If an implementation is not careful, race conditions could cause Secondaries to install an inconsistent set of updates (for example, some ECUs would install updates from one Primary, whereas others would install updates from another Primary). This can cause ECUs to fail to interoperate.

If multiple Primaries are active in the vehicle at the same time, then each Primary SHOULD control a mutually exclusive set of Secondaries, so that each Secondary is controlled by one Primary.

### TODO Write rationale for the SHOULD noted above.

## Atomic installation of a bundle of images

An OEM may wish to require atomic installation of a bundle of images, which means that either all updates in a bundle are installed, or, should one or more fail, none of them are installed. Uptane does not provide a way to guarantee such atomic installation because the problem is out of its scope. It is challenging for ECUs to atomically install a bundle in the face of arbitrary failure: if just one ECU fails to install its update in the bundle for any reason (such as hardware failure), then the guarantee is lost. Furthermore, different OEMs and suppliers already have established ways of solving this problem. Nevertheless, we discuss several different solutions for those who require guidance on this technique.

The simplest solution is to use the vehicle version manifest to report to the Director repository any failure to atomically install a bundle, and then not retry installation. After receiving the report, it is up to the OEM to decide how to respond. For example, the OEM MAY require the owner of the vehicle to diagnose the failure at the nearest dealership or authorized mechanic.

Another simple solution is for the Primary and / or Director to retry a bundle installation until it succeeds (bounded by a maximum number of retries). This solution does not require ECUs to perform a rollback in case a bundle is not fully installed, which is advantageous as ECUs without additional storage cannot perform such a rollback. 

If all ECUs do have additional storage, and can perform a rollback, then the OEM may use a [two-phase commit protocol](https://en.wikipedia.org/wiki/Two-phase_commit_protocol). We assume that a gateway ECU would act as the coordinator, which ensures that updates are installed atomically. This technique should ensure atomic installation as long as: (1) the gateway ECU behaves correctly and has not been compromised, and (2) the gateway ECU does not fail permanently. It is considerably less complicated than Byzantine-fault tolerant protocols, which may have a higher computation/communication overhead. However, this technique does not provide other security guarantees. For example, the gateway ECU may show different bundles to different Secondaries at the same time.

## 2nd-party Fleet management

<img align="center" src="assets/images/custom_2_fleet_management.png" width="500" style="margin: 0px 20px"/>

**Figure 2.** *Two options for fleet management with Uptane.*

Some parties, such as vehicle rental companies or the military, may wish to exercise control on how their own fleet of vehicles are updated. Uptane offers two options for implementing fleet management, as illustrated in Figure 2. Choosing between these options depends on whether the fleet manager wishes to have either complete control, or better compromise-resilience.

In the first option, which we expect to be the common case, a fleet manager would configure the map file on ECUs, such that Primaries and full verification Secondaries would trust an image if and only if it has been signed by both the Image repository managed by the OEM, and the Director repository, which would be managed by the fleet. Partial verification Secondaries would trust an image if and only if it has been signed by this Director repository. The upside of this option is that the fleet manager, instead of the OEM, has complete control over which updates are installed on its vehicles. The downside of this option is that, if the Directory repository controlled by the fleet manager is compromised, then attackers can execute mix-and-match attacks.

In the second option, a fleet manager would configure the map file on ECUs such that Primaries and full verification Secondaries would trust an image if and only if it has been signed by three repositories: the OEM-managed Image repository, the OEM-managed Director repository, and the fleet-managed Director repository. The upside of this option is that attackers cannot execute mix-and-match attacks if they have compromised only the Director repository managed by either the OEM or the fleet. The downside of this option is that updates cannot be installed on vehicles unless both the OEM and fleet agree on which images should be installed together. This agreement may require both Director repositories to communicate using an out-of-band channel. Using this option also means that partial verification Secondaries should be configured to trust the Director repository managed by either the OEM or the fleet, but not both, since these Secondaries can only check for one signature.

## User-customized updates

<img align="center" src="assets/images/custom_3_thirdparty_updates.png" width="500" style="margin: 0px 20px"/>

**Figure 3.** *An OEM MAY allow a third party to negotiate which updates are installed.*

In its default implementation, Uptane allows only the OEM to fully control which updates are installed on which ECUs on which vehicles. Thus, there is no third party input about updates from a dealership, mechanic, fleet manager, or the end-user. There are very good reasons, such as legal considerations, for enforcing this constraint. However, sharing this capability exists to the point that the OEM wishes to make it available. We discuss two options for doing so.

In the first option, an OEM MAY elect to receive input from a third party as to which updates should be installed. The process is illustrated in Figure 3. In the first step, the vehicle would submit its vehicle version manifest to the Director repository controlled by the OEM. The manifest lists which updates are currently installed. In the second step, the Director repository would perform dependency resolution using this manifest, and propose a set of updates. In the third step, the third party would either agree with the OEM, or propose a different set of updates. This step SHOULD be authenticated (e.g., using client certificates, or username and password encrypted over TLS), so that only authorized third parties are allowed to negotiate with the OEM. In fourth step, the OEM would either agree with the third party, or propose a different set of updates. The third and fourth steps MAY be repeated up to a maximum number of retries, until both the OEM and the third party agree as to which updates should be installed.

### TODO Write rationale for the SHOULD noted above.

In the second option, the third party MAY choose to override the root of trust for ECUs, provided that the OEM makes this possible. Specifically, the third party may overwrite the map and root metadata file on ECUs, so that updates are trusted and installed from repositories managed by the third party, instead of the OEM. The OEM may infer whether a vehicle has done so, by monitoring from its inventory database whether the vehicle has recently updated from its repositories. The OEM MAY choose not to make this option available to third parties by, for example, using a Hardware Security Module (HSM) to store Uptane code and data, so that third parties cannot override the root of trust.

## ECUs without filesystems

Currently, implementation instructions are written with the implicit assumptions that: (1) ECUs are able to parse the string filenames of metadata and images, and that (2) ECUs may have filesystems to read and write these files. However, not all ECUs, especially partial verification Secondaries, may fit these assumptions. There are two important observations.

First, filenames need not be strings. Even if there is no explicit notion of "files" on an ECU, it is important for distinct pieces of metadata and images to have distinct names. This is needed for Primaries to perform full verification on behalf of Secondaries, which entails comparing the metadata for different images for different Secondaries. Either strings or numbers may be used to refer to distinct metadata and images, as long as different “files” have different "file" names or numbers. The Image and Director repositories can continue to use file systems, and may also use either strings or numbers to represent "file" names.

Second, ECUs need not have a filesystem in order to use Uptane. It is only important that ECUs are able to recognize distinct metadata and images, using either strings or numbers as "file" names or numbers, and that they allocate different parts of storage to different "files."

## Custom installation instructions for ECUs

Most inputs to ECUs are delivered as signed Targets files and are stored on the Image directory. These signed Targets files are then sent to the ECU by the Director. However, there may be some cases where the inputs required for a particular customization cannot be configured to follow this standard signing process. Variations in input may be due to not knowing the input in advance, or a need to customize instructions for each vehicle. Examples of such inputs could be a command line option that turns on a feature in certain ECUs, a configuration sent by a Director repository to an ECU, or a Director doing a dynamic customization for an ECU. We can collectively call all these non-standard inputs "dynamic directions." Uptane allows ECUs to access dynamic directions in two different ways, each having particular advantages for different use cases.

### Accessing dynamic directions through signed images from the Director repository

The first option for providing dynamic directions is to slightly modify the standard delivery procedure described above. A signed image would still be sent to the ECU from the Director repository, but with one main difference. Though this file will be signed by the Director, Timestamp, and Metadata roles, it would not be stored on—-or validated by—-the Image repository. As the Image repository is controlled by offline keys, it can not validate a file created dynamically by the Director.

Even though the Image repository can not sign the file, some security protections are still offered by this modification. The ECU would continue to have rollback protection for a file sent this way, as a release counter will still be included in the metadata and be incremented for each new version. If additional validation is needed, the file could be put on multiple repositories created for this purpose. These repositories could behave similar to the Director repository, but would all have separate keys to allow for additional security. The Primary ECU will be aware of these extra repositories so it can check for consistency by downloading and comparing the image from all repositories.

### Adding dynamic directions to the custom field of Targets metadata

Another way to provide dynamic directions is to use the custom field of the Targets metadata file. This field provides the option to include custom inputs to individual ECUs. Using the custom field is an especially good option for managing small variations in the existing image. For example, a compilation flag to enable a navigation feature might be set on some ECUs, but not on others. The custom field could contain dynamic directions, and additional subfields would help determine for which ECUs the direction is intended. In the flag example above, the Director can put the ECU id and the flag into the custom field so the flag will be used during the installation process only on that particular ECU. This custom field can then be included in the Targets metadata received by all ECUs. The intended ECU would be able to check for this flag and use it during an installation or update to enable the navigation system.

Using this method of providing dynamic directions offers several ways to secure the system. The Targets metadata is created by the Director, validated using the Timestamp, and stored in the Image repository. As an added protection against a compromise of the Director role, the custom field could also be included in the Targets metadata file on the Image repository. This option works best if there is only a small set of known customizations. However, if there are multiple customization possibilities, the better option would be to store the Targets metadata without the custom field in the Image repository, and keep the custom field configured separately and signed by the Director.

### Picking an option (Efficiency vs Security)

In choosing whether to send dynamic variations from the Director repository or through the custom field of Targets metadata, one needs to consider two factors: how quickly the dynamic direction needs to be received, and how security-sensitive the receiving ECU may be. If dynamic directions are sent using the custom field of Targets metadata, these directions will be downloaded by all ECUs on the car. So, if the direction has a large file size, it could significantly slow down delivery of the metadata. Sending files from the Director repository that are signed only for a specific ECU could be a bit more efficient. Yet if the ECUs are connected on a single bus, there is no way to avoid this large quantity of data going to all units.

In terms of security, dynamic direction transmission through the custom field of Targets metadata seems to have an advantage, as it gives the sender the option of storing these directions on the Image repository. This would offer protection against a compromised Director repository. In contrast, files sent from the Director to a specific ECU are only signed by the Director. In case of a compromise, images signed only by the Director could be changed without the ECU knowing.

It is important to consider these tradeoffs when deciding how to send dynamic directions. If the ECU is security critical, these directions should be sent using the custom field of Targets metadata and stored on the Image repository. If the dynamic directions are large or there are efficiency concerns, the directions should be sent as signed images from the Director repository.
