---
layout: default
css_id: security_considerations
---

# Enhanced security practices

Uptane is a flexible system and therefore can be adapted for increased security
if an OEM or supplier deems it necessary. In this section, we discuss several of these techniques.

### Restricting image installation with custom hardware IDs

Before an ECU installs a new image, it SHOULD always check the hardware type of the image. This can prevent attackers from causing an ECU to install arbitrary images it was not intended to have. Furthermore, an OEM and/or its suppliers SHOULD include certain information about images in the Targets metadata to prevent the installation of these arbitrary images if the Director repository should be compromised.

Consider the following example in which attackers have compromised the Director repository. If certain mitigating steps have been taken, such as using release counters, they cannot rollback software updates. Furthermore, without an additional key compromise, attackers cannot cause arbitrary software attacks on Primaries and full verification Secondaries. However, attackers can cause the ECUs of one hardware type to install images intended for another hardware type. To use an analogy, this is similar to causing [Linksys](https://www.linksys.com/us/) routers to install images intended for [NetGear](https://www.netgear.com/) routers.

Simply having ECU identifiers (e.g., serial numbers) specified in the Targets metadata signed by the Director repository does not solve this problem because: (1) they are used by the Director repository only to instruct which ECU should install which image, and (2) they are not specified in the Targets metadata signed on the Image repository because it is impractical to list all ECU identifiers that pertain to an image.

In order to avoid this problem, the custom Targets metadata about unencrypted images on the Image repository SHOULD always include hardware identifiers. A hardware identifier allows an OEM and/or its suppliers to succinctly capture an entire class of ECUs without listing each of their identifiers. Note that the OEM and/or its suppliers SHOULD ensure that hardware identifiers are unique across different hardware types of ECUs, so that attackers who compromise the Director repository cannot cause ECUs of one type to install images intended for another type.

### Integrating software supply chain security into Uptane
As new legislation emerges in the wake of several high profile supply chain attacks, automakers need to consider implementing more effective end-to-end security measures for software. Both the UNECE WP.29 regulations that went into effect in some parts of the world in June 2020, and the ISO/SAE 21434 Standard published in the summer of 2021 require OEMs to ensure that the entire automotive supply chain is secure. In the United States, [Executive Order 14028](https://www.whitehouse.gov/briefing-room/presidential-actions/2021/05/12/executive-order-on-improving-the-nations-cybersecurity/) observes that "The development of commercial software often lacks transparency, sufficient focus on the ability of the software to resist attack, and adequate controls to prevent tampering by malicious actors," and calls for a concerted effort to correct this situation. 

There are a number of complementary supply chain security technologies that might be adapted for these purposes. The [in-toto](https://in-toto.io/) framework is a common link between a number of these efforts. The framework breaks down the software supply chain into a series of steps, each of which has a “functionary,” human or otherwise, authorized to perform it. A policy is defined for each supply chain and it is then cryptographically signed by the supply chain owner. As each functionary performs its task, it captures separate signed metadata that documents the artifacts involved. The metadata is then validated against the policy, ensuring only authorized actions or operations were performed in the supply chain.

in-toto has already been successfully adopted or integrated into several major open source software projects, including those hosted by the Cloud Native Computing Foundation, a part of the Linux Foundation. It has already been used in tandem with The Update Framework (TUF) to provide both end-to-end security and compromise resilience for [Datadog](https://www.datadoghq.com/blog/engineering/secure-publication-of-datadog-agent-integrations-with-tuf-and-in-toto/). Using this integration as a guide, the Uptane community published [Scudo](https://uptane.github.io/papers/scudo-whitepaper.pdf), a whitepaper that describes how to use in-toto and Uptane together to provide security guarantees for the development _and_ delivery of automotive software. A [Proposed Uptane Revision and Enhancement (PURE)](https://github.com/uptane/pures) describing [Scudo's implementation details](https://github.com/uptane/pures/blob/main/pure3.md) was accepted on 2/28/23.

### Secure alternatives to conventional software and identifiers  
Having an unambiguous way to reference all of its components is a crucial attribute within any system. Therefore, taking a closer look at a system’s identifiers—both hardware and software—can be a worthwhile investment in enhancing system security. A system that lacks a standardized and widely accepted system of identifying components presents a potential vulnerability that can impact both the efficiency and reliability of operations. Thus, designers, suppliers, and OEMs have come to realize that the identifiers used for both the hardware or software element on a vehicle are not trivial details. Despite the emergence of alternative ECU and software ID strategies, the utilization of VIN numbers, often as the only hardware identifier on a vehicle, is still all too common a practice.

Uptane recognizes the need to adopt stronger identifiers, and future versions of this document will present strategies for upgrading the security and reliability of both ECU and software IDs. In both cases, we will consult and comply with the latest regulations and international standards. For ECU IDs, any design proposals will likely follow the example presented in the [IEEE Standard 802.1AR Device Identity](https://1.ieee802.org/security/802-1ar/), which specifies “Secure Device Identifiers (DevIDs)  designed to be used as interoperable secure device authentication credentials with Extensible Authentication Protocol (EAP) and other industry standard authentication and provisioning protocols.” The document makes the case that utilizing a standardized device identity makes the authentication of interoperable secure devices easier, and simplifies secure device deployment and management.

For software ID tags any proposed actions will likely be guided by the Internet Engineering Task Force’s in-process Standard on [Concise Software Identification Tags](https://datatracker.ietf.org/doc/draft-ietf-sacm-coswid/). This Standard describes a new type of Software Identification (SWID) tag that “supports a similar set of semantics and features as SWID tags, as well as new semantics” that “allow the tags to describe additional types of information, all in a more memory efficient format.” The “Co” in CoSWID stands for concise, as it significantly reduces the amount of data transported as compared to a typical SWID tag. To make this happen, CoSWIDs use the technique of Concise Binary Object Representation (CBOR), first defined in [RFC8949](https://datatracker.ietf.org/doc/html/rfc8949). According to [Wikipedia](https://en.wikipedia.org/wiki/CBOR),  CBOR “is a binary data serialization format loosely based on JSON” that “allows the transmission of data objects that contain name–value pairs, but in a more concise manner.” Though this increases processing and transfer speeds at the cost of human readability, the process is designed to automate a task that previously would require human intervention. Therefore, any trade-off in the readability of content would be negligible compared to the enhanced security value.

At this point, Uptane is not planning any imminent change in its Standard to mandate what qualifies as secure hardware or software identifiers, but we do strongly suggest adopters consider alternatives beyond just VIN numbers. Given the growing desirability of automotive systems as targets of hacking, identity is too important for security to trust to just a part number.

### Preventing rollback attacks in case of Director compromise

In the [Exceptional Operations](https://uptane.github.io/deployment-considerations/exceptional_operations.html#rolling-back-software) section of this document, we discuss how an OEM and/or its suppliers SHOULD use release counters in order to prevent rollback attacks in case of a Director repository compromise. To further limit the impact of such an attack scenario, the OEM and/or its suppliers SHOULD also use the following recommendations.

First, they SHOULD diligently remove obsolete images from new versions of Targets metadata files uploaded to the Image repository. This can prevent attackers who compromise the Director repository from being able to choose these obsolete images for installation. This method has a downside in that it complicates the update process for vehicles that require an intermediate update step. For example, an ECU has previously installed image A, and C is the latest image it should install. However, the ECU should install image B before it installs C, and B has already been removed from the Targets metadata on the Image repository in order to prevent or limit rollback attacks. Thus, the OEM and/or its suppliers needs to carefully balance these requirements in making the decision to remove obsolete images from the Targets metadata.

Second, they SHOULD decrease the expiration timestamps on all Targets metadata uploaded to the Image repository so they expire more quickly. This can prevent attackers who compromise the Director repository from being able to choose these obsolete images. Unfortunately, Targets metadata that expires quickly needs to be updated more frequently. This may make it harder to prevent accidental freeze attacks, as an ECU needs to be able to update both the time and the metadata from the Image repository. In the event that the ECU is able to update metadata, but not the time, it can continue working with the previously installed image, but would be unable to update to the latest image. The Director repository can detect this unlikely event using the vehicle version manifest. In this case, the OEM MAY require the owner of the vehicle to diagnose the problem at the nearest dealership or authorized mechanic.

### Broadcasting vs. unicasting metadata inside the vehicle

An implementation of Uptane MAY have a Primary unicast metadata to Secondaries. In this scenario, the Primary would send metadata separately to each Secondary. However, this method is vulnerable to network disruptions and can cause ECUs to see different versions of metadata released by repositories at different times.

In order to mitigate this problem, it is RECOMMENDED that a Primary use a broadcast network, such as CAN, CAN FD, or Ethernet to transmit metadata to all of its Secondaries at the same time. Note that this still does not guarantee that ECUs will always see the same versions of metadata at any time. This is because network traffic between Primaries and Secondaries may still get disrupted, especially if they are connected through intermediaries, such as gateways. Nevertheless, it should still be better than unicasting.

If an update is intended to be applied to a gateway itself, it should be updated either before or after (but not during) update operations to ECUs on the other side of the gateway. This can help to avoid the disruption described above.

### Dependencies and conflicts between ECUs

When installing an image on any given ECU, there may be *dependencies*, or a set of other images that SHOULD also be installed on other ECUs in order for the image to work. Likewise, the same image and ECU may have *conflicts*, or a set of other images that SHOULD NOT be installed on other ECUs. *Dependency resolution* is the process of determining which versions of the latest images and their dependencies can be installed without conflicts.

#### Checking dependencies and conflicts

There are three options for checking dependencies and conflicts:

1. **Only ECUs check dependencies and conflicts.** This information should be included in the Targets metadata on the Image repository, and should not add substantially to bandwidth costs. The upside is that, without offline keys, attackers cannot cause ECUs to fail to satisfy dependencies and prevent conflicts. The downside is that it can add to computational costs, because dependency resolution is generally [an NP-hard problem](https://research.swtch.com/version-sat). However, it is possible to control the computational costs if some constraints are imposed.
2. **Only the Director repository checks dependencies and conflicts.** This is currently the default on Uptane. The upside is that the computational costs are pushed to a powerful server. The downside is that attackers who compromise the Director repository can tamper with dependency resolution.
3. **Both ECUs and the Director repository check dependencies and conflicts.** To save computational costs, and avoid having each ECU perform dependency resolutions, only the Primaries and full verification Secondaries may be required to double-check the dependency resolution performed by the Director repository. Note that this is not an NP-hard problem because these ECUs simply need to check that there is no conflict between the Director and Image repositories. The trade-off is that when Primaries are compromised, Secondaries have to depend on the Director repository.

#### Managing dependencies and conflicts

Generally speaking, the Director repository SHOULD NOT issue a new bundle that may conflict with images listed on the last vehicle version manifest, and therefore known with complete certainty to have been installed on the vehicle. This is because a partial bundle installation attack could mean the ECUs have only partly installed any images sent after the last vehicle version manifest. If the Director repository is not careful in handling this issue, the vehicle may end up installing conflicting images that will cause ECUs to fail to interoperate.

![](assets/images/security_1_exchange_director_vehicle.png)

**Figure 1.** *A series of hypothetical exchanges between a Director repository and a vehicle.*

Consider the series of messages exchanged between a Director repository and a vehicle in Figure 1.

* In the first bundle of updates, the Director repository instructs ECUs A and B to install the images A-1.0.img and B-1.0.img, respectively. Later, the vehicle sends a vehicle version manifest stating that these ECUs have now installed these images.

* In the second bundle, the Director repository instructs these ECUs to install the images A-2.0.img and B-2.0.img, respectively. However, for some unknown reason, the vehicle does not send a new vehicle version manifest in response.

* In the third bundle of updates, the Director repository instructs these ECUs to install the images A-3.0.img and B-3.0.img. However, it has not received a new vehicle version manifest from the vehicle stating that both ECUs have installed the second bundle. Furthermore, the Director repository knows that B-1.0 and C-3.0 conflict with each other. The only thing the Director repository can be certain of is that B has installed either B-1.0 or B-2.0, and C has installed either C-1.0 or C-2.0. Thus, the Director repository SHOULD NOT send the third bundle to the vehicle, because B-1.0 from the first bundle may still be installed, which would conflict with C-3.0 from the third bundle.

* Therefore, the Director repository SHOULD NOT issue the third bundle until it has received a vehicle version manifest from the vehicle that confirms that ECUs B and C have installed the second bundle, which is known to contain images that do not conflict with the third bundle.

* In conclusion, the Director repository SHOULD NOT issue a new bundle until it has received confirmation via the vehicle version manifest that no image known to have been installed conflicts with the new images in the new bundle.

If the Director repository is not able to update a vehicle for any reason, then it SHOULD raise the issue to the OEM.


### ASN.1 decoding

If an OEM chooses to use ASN.1 to encode and decode metadata and other messages, then it SHOULD take great care in decoding the ASN.1 messages. Improper decoding of ASN.1 messages may lead to arbitrary code execution or denial-of-service attacks. For example, see [CVE-2016-2108](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-2108) and attacks on a [well-known ASN.1 compiler](https://arstechnica.com/information-technology/2016/07/software-flaw-puts-mobile-phones-and-networks-at-risk-of-complete-takeover/).

In order to avoid these problems, whenever possible OEMs and suppliers SHOULD use ASN.1 decoders that have been comprehensively tested via unit tests and fuzzing.

Furthermore, following best practices, we recommend that DER encoding is used instead of BER and CER, because DER provides a unique encoding of values.


### Balancing EEPROM performance and security

Many ECUs use EEPROM which, practically speaking, can be written to only a limited number of times. This in turn can impose limits on how often these ECUs can be updated.

In order to analyze this problem, let us recap what new information should be downloaded in every software update cycle:

1. The Primary writes and sends the latest vehicle version manifest to the Director repository.
2. All ECUs download, verify, and write the latest downloaded time from its source of current accurate time.
3. All ECUs download, verify, and write metadata from the Director and/or Image repositories.
4. At some point, ECUs download, verify, and write images.
5. At some point, ECUs install new images. Then, they sign, and write the latest ECU version reports.

Let us make two important observations.

First, it is not necessary to continually refresh the time apart from a software update cycle. This is because: (1) the time may not be successfully updated, (2) an ECU SHOULD be able to boot to a valid image, even if its metadata has expired, and (3) it is necessary to check only that the metadata for the latest downloaded updates has not expired.

Indeed, there is a risk to implementers updating time information too frequently. For example, if time information is made once per day, it can cause flash devices with 10K write lifetime to wear out within roughly 27 years.  If valid time metadata is always written to the same block, an admittedly unlikely scenario since the old metadata is likely to be retained before the new metadata is validated, this may cause unacceptable wear. Implementers should seriously consider both the lifetime usage of their devices and their likely update patterns if using technologies with limited writes.

However, there is a trade-off between frequently updating the current time (and thus, exhausting EEPROM), and the efficacy of the system to prevent freeze attacks from a compromised Director repository. If it is essential to frequently update the time to prevent freeze attacks, and EEPROM must be used, there are ways to make that use more efficient. For example, the ECU may write data to EEPROM in a circular fashion that can expand its lifetime of wear.

Second, it is not necessary for ECUs to write and sign an ECU version report upon every boot or reboot cycle. At a minimum, an ECU should write and sign a new ECU version report only upon the successful verification and installation of a new image.


### Balancing security and bandwidth

When deploying any system, it is important to think about the costs involved.  Those can roughly be partitioned into computational, network (bandwidth), and storage.  This subsection gives a rough sense of how those costs may vary depending upon the deployment scenario employed.  The numbers quoted are not authoritative, but do express order of magnitude costs.

A Primary will end up retrieving and verifying any updated metadata from the repositories it communicates with, which usually means an Image repository and a Director repository will be contacted.  Whenever an image is added to the Image repository, a Primary will download a new Targets, Snapshot, and Timestamp metadata file.  The Root file is updated less frequently, but when this is done, it may also need to be verified.  Verifying these repositories and roles entails checking a signature on each of the files.  Whenever the vehicle is requested to install an update, the Primary also receives a new piece of metadata for the Targets, Snapshot, and Timestamp roles, and on rare occasions, from the Root file. As noted above, this verification requires a signature check.  A Primary must also compute the secure hash of all images it will serve to ECUs.  The previous known good version of all metadata files must be retained.  It is also wise to retain any images until Secondaries have confirmed installation.

A full verification Secondary is nearly identical in cost to a Primary.  The biggest difference is that it has no need to store, retrieve, or verify an image that it is not destined to receive.  However, other costs are fundamentally the same.

A partial verification Secondary merely retrieves Targets metadata when it changes, and any images it will install.  This requires one signature check and one secure hash operation per software installation.

Note also that, if used, an external source of time costs are typically for one signature verification per ECU per time period of update (e.g., daily).  This cost varies based upon the algorithm and thus its measurement can only be estimated based upon the algorithm.

### Using encrypted images on the Image repository

Images stored on the Image repository may have previously been encrypted or not, at the discretion of the implementer.  The Standard does not explicitly mention using encrypted images on the Image repository because Uptane treats these blobs exactly the same as unencrypted blobs. It only imposes special requirements on images that are per-ECU encrypted on the Director repository. Therefore, there is no reason that encrypted images cannot be on the Image repository should an implementer wish to use them.

### Avoiding Director replay attacks

Uptane doesn't explicitly require that Targets metadata from the Director contain any images at all.

As such, it may be tempting to only include software images that need to be updated in a Director's Targets metadata, for efficiency and bandwidth-minimization reasons. Yet, such an action implies that empty Targets metadata would be sent if no updates are available. Sending empty Targets metadata with only the required fields presents a potential security threat. As empty metadata does not include any ECU- or vehicle-specific information, it could potentially be replayed to another vehicle, creating a "freeze" attack, since the targeted vehicle would continue to believe it was fully updated. (See [uptane-standard issue #202](https://github.com/uptane/uptane-standard/issues/202) for a more detailed discussion.)

There are two straightforward mitigations for this issue:

* Don't allow the Director to issue empty Targets metadata. For example, you could always include the image installed on the Primary ECU. This mitigation requires no client-side changes.
* Include the targeted VIN number (or some other vehicle identifier) in the Director Targets metadata. We recommend using a top-level "vin" or "device_id" field for this purpose. The client should then add a verification step checking that the VIN matches its own. If there is a mismatch, the client should abort the update cycle and report an error.

The latter mitigation will likely be included as a requirement in a future release of the Uptane standard.

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
