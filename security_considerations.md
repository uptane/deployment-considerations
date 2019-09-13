---
layout: default
css_id: security_considerations
---

# Additional security considerations and recommendations

Uptane is a flexible system and therefore can be adapted for increased security
if an OEM or supplier deems it necessary. In this section, we discuss several of these techniques.

## Restricting image installation with custom hardware IDs

In order to prevent attackers who compromise the director repository from causing one type of ECU to install images intended for another type, an OEM and / or its suppliers SHOULD include certain information about images in the Targets metadata.

Suppose attackers have compromised the Director repository. If release counters are used and further mitigating steps are taken, they can not rollback software updates. Furthermore, without an additional key compromise, attackers cannot cause arbitrary software attacks on Primaries and full verification Secondaries. However, attackers can cause ECUs of one hardware type to install images intended for another hardware type. To use an analogy, this is similar to causing Linkedsys routers to install images intended for GetNear routers.

ECU identifiers (e.g., serial numbers) specified in the Targets metadata signed by the Director repository do not solve this problem, because: (1) they are used by the Director repository only to instruct which ECU should install which image, and (2) they are not specified in the Targets metadata signed on the Image repository, because it is impractical to list all ECU identifiers that pertain to an image.

In order to avoid this problem, the Targets metadata about unencrypted images on the Image repository SHOULD always include the TargetsModule.Custom.hardwareIdentifier attribute. A hardware identifier allows an OEM and / or its suppliers to succinctly capture an entire class of ECUs without listing each of their ECU identifiers. Note that the OEM and / or its suppliers SHALL ensure that hardware identifiers are unique across different hardware types of ECUs, so that attackers who compromise the Director repository cannot cause ECUs of one type to install images intended for another type.

Before an ECU installs a new image, it SHOULD always check the hardware type of the image so that attackers cannot cause any ECU to install randomly chosen images not intended for it.

## Preventing rollback attacks in case of Director compromise

On the[Exceptional Operations](https://github.com/uptane/deployment-considerations/blob/master/exceptional_operations.md) page, we discussed how an OEM and / or its suppliers SHOULD use release counters in order to prevent rollback attacks should the Director repository be compromised. To further limit these attacks in this scenario, the OEM and / or its suppliers SHOULD also use the following recommendations.

First, they SHOULD diligently remove obsolete images from new versions of Targets metadata files uploaded to the Image repository. This can prevent attackers who compromise the Director repository from being able to choose these obsolete images for installation. This method has a downside in that it complicates the update process for vehicles that require an intermediate update step. For example, an ECU has previously installed image A, and C is the latest image it should install. However, the ECU should install image B before it installs C, and B has already been removed from the Targets metadata on the Image repository in order to prevent / limit rollback attacks. Thus, the OEM and / or its suppliers SHOULD balance between the requirement to remove obsolete images from the Targets metadata, and the need to support ECUs that require installation of these obsolete images before updating to the latest images.

Second, they SHOULD decrease the expiration timestamps in the Targets metadata uploaded to the Image repository. This is done so that these Targets metadata expire more quickly, thus preventing attackers who compromise the Director repository from being able to choose these obsolete images. This method also has a downside, since these Targets metadata now need to be updated more quickly. To prevent accidental freeze attacks, an ECU needs to be able to update both the time from the time server, and metadata from the Image repository.  In this unlikely event that the ECU is able to update metadata, but not the time, it can continue working with the previously installed image, but would be unable to update to the latest image. The Director repository can detect this unlikely event using the vehicle version manifest. In this case, the OEM MAY require the owner of the vehicle to diagnose the problem at the nearest dealership or authorized mechanic.

## Broadcasting vs. unicasting metadata inside the vehicle
An implementation of Uptane MAY have a Primary unicast metadata to Secondaries. In this scenario, the Primary would send metadata separately to each Secondary. However, this has a downside: due to network disruptions, different ECUs may end up seeing different versions of metadata released by repositories at different times.

In order to mitigate this problem, it is RECOMMENDED that a Primary use a broadcast network such as CAN, CAN FD, or Ethernet to transmit metadata to all of its Secondaries at the same time. Primaries MAY use the ECUModule.MetadataFiles message to do so. Note that this still does not guarantee that different ECUs will not end up seeing different versions of metadata released by repositories at different times. This is because network traffic between Primaries and Secondaries may still get disrupted, especially if they are connected through intermediaries, such as gateways. Nevertheless, it should still be better than unicasting.

If an update is intended to be applied to a gateway itself, it should be updated either before or after (but not during) update operations to ECUs on the other side of the gateway, so as to avoid disruption.

## Checking for dependencies and conflicts

The *dependencies* for a given ECU is the set of other images that SHOULD also be installed on other ECUs in order for that image to work on a particular ECU. The *conflicts* for the same image and ECU is the set of other images that SHOULD not be installed on other ECUs in order for the image to work correctly on this ECU. Dependency resolution is the process of finding which versions of the latest images and their dependencies can be installed without conflicts.

There are three options for which entities should check dependencies and conflicts:

1. **Only ECUs check dependencies and conflicts.** This information should be included in the Targets metadata on the Image repository, and should not add substantially to bandwidth costs. The upside is that, without offline keys, attackers cannot cause ECUs to fail to satisfy dependencies and prevent conflicts. The downside is that it can add to computational costs, because dependency resolution is generally an NP-hard problem. However, it is possible to control the computational costs if some constraints are imposed.
2. **Only the Director repository checks dependencies and conflicts.** This is currently the default on Uptane. The upside is that the computational costs are pushed to a powerful server. The downside is that attackers who compromise the Director repository can tamper with dependency resolution.
3. **Both ECUs and the Director repository check dependencies and conflicts.** To save computational costs, and avoid having each ECU perform dependency resolutions, only the Primaries and full verification Aecondaries may be required to double-check the dependency resolution performed by the Director repository. Note that this is not NP-hard problem, because these ECUs simply need to check that there is no conflict between the Director and image repositories. The trade-off is that when primaries are compromised, Secondaries have to depend on the Director repository.

## Checking for dependencies and conflicts
Generally speaking, the Director repository SHOULD NOT issue a new bundle that may conflict with images known with complete certainty to have been installed on the vehicle, as listed on the last vehicle version manifest. This is because a partial bundle installation attack could mean any bundle sent after the last vehicle version manifest may have been only partly installed by ECUs. If the Director repository is not careful in handling this issue, the vehicle may end up installing conflicting images, causing ECUs to fail to interoperate.

<img align="center" src="assets/images/security_1_exchange_director_vehicle.png" width="500" style="margin: 0px 20px"/>

**Figure 1.** *A series of hypothetical exchanges between a director repository and a vehicle.*

Consider the series of messages exchanged between a Director repository and a vehicle in Figure 1. In the first bundle of updates, the Director repository instructs ECUs A and B to install the images A-1.0.img and B-1.0.img respectively. Later, the vehicle sends a vehicle version manifest stating that these ECUs have now installed these images.
In the second bundle of updates, the director repository instructs these ECUs to install the images A-2.0 img and B-2.0.img respectively. However, for some unknown reason, the vehicle does not send a new vehicle version manifest in response.
In the third bundle of updates, the director repository instructs these ECUs to install the images A-3.0.img and B-3.0.img. However, the problem is that it has not received a new vehicle version manifest from the vehicle in the meantime, stating that both ECUs have installed the second bundle.
Furthermore, the director repository knows that B-1.0 and C-3.0 conflict with each other. The only thing the director repository can be certain of is that B has installed either B-1.0 or B-2.0, and C has installed either C-1.0 or C-2.0. Thus, the director repository SHOULD NOT send the third bundle to the vehicle, because B-1.0 from the first bundle may still be installed, which would conflict with C-3.0 from the third bundle.
Therefore, the director repository SHOULD NOT issue the third bundle, until it has received a vehicle version manifest from the vehicle that confirms that ECUs B and C have installed the second bundle, which is known to contain images that do not conflict with the third bundle.
In conclusion, the director repository SHOULD NOT issue a new bundle until it has received confirmation, using the vehicle version manifest, that no image known to have been installed conflicts with the new images in the new bundle.
If the director repository is not able to update a vehicle for any reason, then it SHOULD raise the issue to the OEM.


## ASN.1 decoding

If an OEM chooses to use ASN.1 to encode and decode metadata and other messages, then it SHOULD be careful in decoding ASN.1 messages. This is because improper decoding of ASN.1 messages may lead to arbitrary code execution or denial-of-service attacks. For example, see CVE-2016-2108 and attacks on a well-known ASN.1 compiler.

In order to avoid these problems, OEMs and suppliers SHOULD use ASN.1 decoders that have been comprehensively tested via unit tests and fuzzing, whenever possible.
Furthermore, following best practices, we recommend that the DER encoding is used instead of BER and CER, because DER provides a unique encoding of values.


## Balancing EEPROM performance and security

Many ECUs use EEPROM which, practically speaking, can be written to for a limited number of times. This limits how often these ECUs can be updated.

In order to analyze this problem, let us recap what new information should be downloaded in every software update cycle:

1. The primary writes and sends the latest vehicle version manifest to the director repository.
2. All secondaries write and send to the primaries fresh tokens for the time server.
3. All ECUs download, verify, and write the latest downloaded time from the time server.
4. All ECUs download, verify, and write metadata from the director and / or image repositories.
5. At some point, ECUs download, verify, and write images.
6. At some point, ECUs install new images. Then, they sign, and write the latest ECU version manifests.

Let us make two important observations.

First, it is not necessary to continually refresh the time from the time server, separately from a software update cycle. This is because: (1) the time may not be successfully updated from the time server, (2) an ECU MUST be able to boot to a valid image even if its metadata has expired, and (3) it is necessary to check only that the metadata for the latest downloaded updates has not expired.

Care must be taken by implementers not to update time information too frequently.  Writing time information once per day, will cause flash with 10K write lifetime to wear out within about 27 years.  If valid time server metadata is always written to the same block (which is unlikely since the old metadata is likely to be retained before the new metadata validated), this may cause unacceptable wear.  Implementers should reason about the lifetime of devices and their likely update patterns when using technologies with limited writes.

However, note that there is a trade-off between frequently updating the time from the time server (and thus, exhausting EEPROM), and the efficacy of preventing freeze attacks by a compromised director repository. If it is important to more frequently update the time, and thus better prevent freeze attack, despite using EEPROM, note that there are ways to make more efficient use of EEPROM. For example, the ECU may write data to EEPROM in a circular fashion, so that the EEPROM is exhausted less quickly.

Second, it is not necessary for ECUs to write and sign an ECU version manifest upon every boot or reboot cycle. At a minimum, an ECU should write and sign a new ECU version manifest only upon the successful verification and installation of a new image.


## Balancing security and bandwidth

When deploying any system, it is important to think about the costs involved.  Those can roughly be partitioned into computational, network (bandwidth), and storage.  To understand these costs, this section gives a rough sense of how those costs vary in based upon the deployment scenario.  These numbers are not authoritative, but are meant to give a rough sense of order of magnitude costs.  

A primary will end up retrieving and verifying any updated metadata from the repositories it communicates with.  This usually means that an image repository and a director repository will be contacted.  Whenever an image is added to the image repository, a primary will download a new targets, snapshot, and timestamp role file.  Rarely, the root file will be updated and may need to also be verified.  Verifying these requires checking a signature on each of the files.  Whenever the vehicle is requested to install an update, the primary also receives a new piece of targets, snapshot, and timestamp metadata.  Rarely, the root file will be updated and may need to also be verified.  As before, verification requires a signature check.  A primary also must compute the secure hash of all images it will serve to ECUs.  The previous, known good version of all metadata files must be retained.  It is also wise to retain any images until secondaries have confirmed installation.

A full verification secondary is nearly identical in cost to a primary.  The biggest difference is that it has no need to store, retrieve, or verify an image that is not destined for it.  Other costs are fundamentally the same.

A partial verification secondary merely retrieves targets metadata when it changes and images it will install.  This requires one signature check and one secure hash operation per software installation.

Note also that time server costs are typically one signature verification per ECU per time period of update (e.g., daily).  This cost varies based upon the algorithm and needs to be measured based upon the algorithm.
