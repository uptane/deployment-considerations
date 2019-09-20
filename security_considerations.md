---
layout: default
css_id: security_considerations
---

# Additional security considerations and recommendations

Uptane is a flexible system and therefore can be adapted for increased security
if an OEM or supplier deems it necessary. In this section, we discuss several of these techniques.

## Restricting image installation with custom hardware IDs

Before an ECU installs a new image, it SHOULD always check the hardware type of the image. This can prevent attackers from causing an ECU to install arbitrary images not intended for it. Furthermore, to prevent attackers who compromise the Director repository from causing unintended images to be installed on any ECU, an OEM and/or its suppliers SHOULD include certain information about images in the Targets metadata.

Consider the following example, where attackers have compromised the Director repository. If certain mitigating steps have been taken, such as using release counters, they can not rollback software updates. Furthermore, without an additional key compromise, attackers cannot cause arbitrary software attacks on Primaries and full verification Secondaries. However, attackers can cause the ECUs of one hardware type to install images intended for another hardware type. To use an analogy, this is similar to causing [Linkedsys](https://www.linksys.com/us/) routers to install images intended for [NetGear](https://www.netgear.com/) routers.

Simply having ECU identifiers (e.g., serial numbers) specified in the Targets metadata signed by the Director repository do not solve this problem, because: (1) they are used by the Director repository only to instruct which ECU should install which image, and (2) they are not specified in the Targets metadata signed on the Image repository, because it is impractical to list all ECU identifiers that pertain to an image.

In order to avoid this problem, the Targets metadata about unencrypted images on the Image repository SHOULD always include the TargetsModule.Custom.hardwareIdentifier attribute. A hardware identifier allows an OEM and/or its suppliers to succinctly capture an entire class of ECUs without listing each of their ECU identifiers. Note that the OEM and/or its suppliers SHALL ensure that hardware identifiers are unique across different hardware types of ECUs, so that attackers who compromise the Director repository cannot cause ECUs of one type to install images intended for another type.

## Preventing rollback attacks in case of Director compromise

On the [Exceptional Operations](https://github.com/uptane/deployment-considerations/blob/master/exceptional_operations.md#rolling-back-software) page, we discuss how an OEM and/or its suppliers SHOULD use release counters in order to prevent rollback attacks in case of a Director repository compromise. To further limit the impact of such an attack scenario, the OEM and/or its suppliers SHOULD also use the following recommendations.

First, they SHOULD diligently remove obsolete images from new versions of Targets metadata files uploaded to the Image repository. This can prevent attackers who compromise the Director repository from being able to choose these obsolete images for installation. This method has a downside in that it complicates the update process for vehicles that require an intermediate update step. For example, an ECU has previously installed image A, and C is the latest image it should install. However, the ECU should install image B before it installs C, and B has already been removed from the Targets metadata on the Image repository in order to prevent or limit rollback attacks. Thus, the OEM and/or its suppliers needs to carefully balance these requirements in making the decision to remove obsolete images from the Targets metadata.

Second, they SHOULD decrease the expiration timestamps on all Targets metadata uploaded to the Image repository so they expire quicker. This can prevent attackers who compromise the Director repository from being able to choose these obsolete images. Unfortunately, this method also has a downside. These Targets metadata will need to be updated quicker as well. To prevent accidental freeze attacks, an ECU needs to be able to update both the time from the Time Server, and metadata from the Image repository.  In this unlikely event that the ECU is able to update metadata, but not the time, it can continue working with the previously installed image, but would be unable to update to the latest image. The Director repository can detect this unlikely event using the vehicle version manifest. In this case, the OEM MAY require the owner of the vehicle to diagnose the problem at the nearest dealership or authorized mechanic.

## Broadcasting vs. unicasting metadata inside the vehicle
An implementation of Uptane MAY have a Primary unicast metadata to Secondaries. In this scenario, the Primary would send metadata separately to each Secondary. However, this has a downside. Network disruptions can cause ECUs to see different versions of metadata released by repositories at different times.

In order to mitigate this problem, it is RECOMMENDED that a Primary use a broadcast network such as CAN, CAN FD, or Ethernet to transmit metadata to all of its Secondaries at the same time. Primaries MAY use the ECUModule.MetadataFiles message to do so. Note that this still does not guarantee that ECUs will not end up seeing different versions of metadata released by repositories at different times. This is because network traffic between Primaries and Secondaries may still get disrupted, especially if they are connected through intermediaries, such as gateways. Nevertheless, it should still be better than unicasting.

If an update is intended to be applied to a gateway itself, it should be updated either before or after (but not during) update operations to ECUs on the other side of the gateway. This can help to avoid the disruption described above.

## Managing dependencies and conflicts between ECUS

The *dependencies* for a given ECU is the set of other images that SHOULD also be installed on other ECUs in order for that image to work on a particular ECU. The *conflicts* for the same image and ECU is the set of other images that SHOULD not be installed on other ECUs if the ECU in question is to work correctly. *Dependency resolution* is the process of determining which versions of the latest images and their dependencies can be installed without conflicts.

### Checking dependencies and conflicts

There are three options for checking dependencies and conflicts:

1. **Only ECUs check dependencies and conflicts.** This information should be included in the Targets metadata on the Image repository, and should not add substantially to bandwidth costs. The upside is that, without offline keys, attackers cannot cause ECUs to fail to satisfy dependencies and prevent conflicts. The downside is that it can add to computational costs, because dependency resolution is generally an NP-hard problem. However, it is possible to control the computational costs if some constraints are imposed.
2. **Only the Director repository checks dependencies and conflicts.** This is currently the default on Uptane. The upside is that the computational costs are pushed to a powerful server. The downside is that attackers who compromise the Director repository can tamper with dependency resolution.
3. **Both ECUs and the Director repository check dependencies and conflicts.** To save computational costs, and avoid having each ECU perform dependency resolutions, only the Primaries and full verification Secondaries may be required to double-check the dependency resolution performed by the Director repository. Note that this is not an NP-hard problem because these ECUs simply need to check that there is no conflict between the Director and Image repositories. The trade-off is that when Primaries are compromised, Secondaries have to depend on the Director repository.

### Managing dependencies and conflicts
Generally speaking, the Director repository SHOULD NOT issue a new bundle that may conflict with images listed on the last vehicle version manifest and thereby known with complete certainty to have been installed on the vehicle. This is because a partial bundle installation attack could mean any bundle sent after the last vehicle version manifest may have been only partly installed by the ECUs. If the Director repository is not careful in handling this issue, the vehicle may end up installing conflicting images, causing ECUs to fail to interoperate.

<img align="center" src="assets/images/security_1_exchange_director_vehicle.png" width="500" style="margin: 0px 20px"/>

**Figure 1.** *A series of hypothetical exchanges between a Director repository and a vehicle.*

Consider the series of messages exchanged between a Director repository and a vehicle in Figure 1. 

* In the first bundle of updates, the Director repository instructs ECUs A and B to install the images A-1.0.img and B-1.0.img, respectively. Later, the vehicle sends a vehicle version manifest stating that these ECUs have now installed these images.

* In the second bundle, the Director repository instructs these ECUs to install the images A-2.0 img and B-2.0.img, respectively. However, for some unknown reason, the vehicle does not send a new vehicle version manifest in response.

* In the third bundle of updates, the Director repository instructs these ECUs to install the images A-3.0.img and B-3.0.img. However, it has not received a new vehicle version manifest from the vehicle stating that both ECUs have installed the second bundle. Furthermore, the Director repository knows that B-1.0 and C-3.0 conflict with each other. The only thing the Director repository can be certain of is that B has installed either B-1.0 or B-2.0, and C has installed either C-1.0 or C-2.0. Thus, the Director repository SHOULD NOT send the third bundle to the vehicle, because B-1.0 from the first bundle may still be installed, which would conflict with C-3.0 from the third bundle.

* Therefore, the Director repository SHOULD NOT issue the third bundle until it has received a vehicle version manifest from the vehicle that confirms that ECUs B and C have installed the second bundle, which is known to contain images that do not conflict with the third bundle.

* In conclusion, the Director repository SHOULD NOT issue a new bundle until it has received confirmation via the vehicle version manifest that no image known to have been installed conflicts with the new images in the new bundle.

If the Director repository is not able to update a vehicle for any reason, then it SHOULD raise the issue to the OEM.


## ASN.1 decoding

If an OEM chooses to use ASN.1 to encode and decode metadata and other messages, then it SHOULD take great care in decoding the ASN.1 messages. Improper decoding of ASN.1 messages may lead to arbitrary code execution or denial-of-service attacks. For example, see [CVE-2016-2108](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-2108) and attacks on a [well-known ASN.1 compiler](https://arstechnica.com/information-technology/2016/07/software-flaw-puts-mobile-phones-and-networks-at-risk-of-complete-takeover/).

In order to avoid these problems, whenever possible OEMs and suppliers SHOULD use ASN.1 decoders that have been comprehensively tested via unit tests and fuzzing.

Furthermore, following best practices, we recommend that DER encoding is used instead of BER and CER, because DER provides a unique encoding of values.


## Balancing EEPROM performance and security

Many ECUs use EEPROM which, practically speaking, can be written to only for a limited number of times. This in turn can impose limits on how often these ECUs can be updated.

In order to analyze this problem, let us recap what new information should be downloaded in every software update cycle:

1. The Primary writes and sends the latest vehicle version manifest to the Director repository.
2. If a Time Server is used, all Secondaries write and send fresh tokens to the Primary. 
3. All ECUs download, verify, and write the latest downloaded time from the Time Server, or whatever device is used to provide the current accurate time.
4. All ECUs download, verify, and write metadata from the Director and/or Image repositories.
5. At some point, ECUs download, verify, and write images.
6. At some point, ECUs install new images. Then, they sign, and write the latest ECU version manifests.

Let us make two important observations.

First, it is not necessary to continually refresh the time apart from a software update cycle. This is because: (1) the time may not be successfully updated, (2) an ECU SHOULD be able to boot to a valid image, even if its metadata has expired, and (3) it is necessary to check only that the metadata for the latest downloaded updates has not expired.

Indeed, there is a risk to implementers updating time information too frequently. For example, if time information is made once per day, it can cause flash devices with 10K write lifetime to wear out within roughly 27 years.  If valid time metadata is always written to the same block, an admittedly unlikely scenario since the old metadata is likely to be retained before the new metadata is validated, this may cause unacceptable wear. Implementers should seriously consider  both the lifetime usage of their devices and their likely update patterns if using technologies with limited writes.

However, there is a trade-off between frequently updating the current time (and thus, exhausting EEPROM), and the efficacy of the system to prevent freeze attacks from a compromised Director repository. If it is essential to frequently update the time to prevent freeze attacks, and EEPROM must be used, there are ways to make that use more efficient. For example, the ECU may write data to EEPROM in a circular fashion that can expand its lifetime of wear.

Second, it is not necessary for ECUs to write and sign an ECU version manifest upon every boot or reboot cycle. At a minimum, an ECU should write and sign a new ECU version manifest only upon the successful verification and installation of a new image.


## Balancing security and bandwidth

When deploying any system, it is important to think about the costs involved.  Those can roughly be partitioned into computational, network (bandwidth), and storage.  To understand these costs, this section gives a rough sense of how those costs may vary based upon the deployment scenario.  These numbers are not authoritative, but are meant to give a rough sense of order of magnitude costs.  

A Primary will end up retrieving and verifying any updated metadata from the repositories it communicates with, which usually means an Image repository and a Director repository will be contacted.  Whenever an image is added to the Image repository, a Primary will download a new Targets, Snapshot, and Timestamp role file.  The Root file is updated less frequently, but when this is done, it may also need to be verified.  Verifying these repositories and roles entails checking a signature on each of the files.  Whenever the vehicle is requested to install an update, the Primary also receives a new piece of metadata for the Targets, Snapshot, and Timestamp roles, and on rare occasions, from the Root file. As noted above, this verification requires a signature check.  A Primary must also compute the secure hash of all images it will serve to ECUs.  The previous known good version of all metadata files must be retained.  It is also wise to retain any images until Secondaries have confirmed installation.

A full verification Secondary is nearly identical in cost to a Primary.  The biggest difference is that it has no need to store, retrieve, or verify an image that it is not destined to receive.  However, other costs are fundamentally the same.

A partial verification Secondary merely retrieves Targets metadata when it changes, and any images it will install.  This requires one signature check and one secure hash operation per software installation.

Note also that, if used, Time Server costs are typically one signature verification per ECU per time period of update (e.g., daily).  This cost varies based upon the algorithm and thus its measurement can only be estimated based upon the algorithm.


