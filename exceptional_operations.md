---
layout: default
css_id: exceptional_operations
---

# Exceptional operations

In this section, we discuss operations that are generally performed only in exceptional cases. As performing these operations may have security implications for software updates, they should be carried out with great care.

## Rolling back software

Sometimes an OEM may determine that the latest updates are less reliable than previous ones.  In that case, it may be necessary to roll back to a previous update.

By default, Uptane does not allow updates to be rolled back and enforces this action with two mechanisms. First, Uptane rejects any new metadata file with a version number lower than the one contained in the previous metadata file. Second, Uptane will reject any new image associated with a release counter that is lower than the release counter of the previous image in the previous Targets metadata file. The first mechanism prevents an attacker from replaying an old metadata file. The second mechanism prevents an attacker who compromises the Director repository from being able to choose old versions of images, despite being able to sign new metadata. See Figure 1 for an example.

![](assets/images/except_1_.rollback_prev.png)

**Figure 1.** *Uptane prevents rollback attacks by rejecting older: (1) metadata files, and/or (2) images.*

There are at least two ways to allow rollbacks, each with different advantages and disadvantages.

In the first option, an OEM MAY choose to never increment the release counters of images (see Figure 2). Uptane will accept any new image associated with a release counter, as long as it is equal to the release counter of the previous image in the previous Targets metadata file. If release counters are never incremented, then all images would have the same release counters. In this situation, an ECU would accept the installation of any compatible image referred to in the new Targets metadata. (See the [Enhanced Security Practices](https://uptane.github.io/deployment-considerations/security_considerations.html) section of this document for more details.)

![](assets/images/except_2_diffimage_samecounter.png)

**Figure 2.** *Uptane allows the installation of images that have the same release counter as what is currently installed.*

The advantage to this method is that it is simple. It allows the OEM to easily install interchangeable versions of the same image. In the example shown in Figure 2, "foo.img" may simply be a version of "bar.img" containing diagnostic functions. Therefore, the OEM may install either "bar.img" or "foo.img" on the same ECU. The disadvantage of this method is that it allows attackers who compromise the Director repository to install obsolete images they can use to execute rollback attacks. Therefore, this method SHOULD NOT be used.

In the second option, an OEM increments the release counter of an image whenever it is critical that an ECU not install images with lower release counters. In the example in Figure 3, if an ECU installs "foo.img," then it cannot install "bar.img." This is done to prevent the installation of compatible images with lower release counters that have known security vulnerabilities, rather than newer images in which these vulnerabilities have been fixed.

![](assets/images/except_3_diffimage_samecounter2.png)

**Figure 3.** *Uptane forbids the installation of images with lower release counters than what is currently installed.*

The advantage to this method is that it prevents rollback attacks in a situation
where attackers compromise only the Director repository.  However, there are two disadvantages. First, the release counters for images have to be maintained, even if role B now signs for images previously signed by role A. This is because release counters are always compared to previous Targets metadata files. Second, it is more cumbersome to roll back updates, or deliberately cause ECUs to install older images, because offline keys are used to increment the release counters of these older images in the new Targets metadata for the Image repository. Yet, this method SHOULD be preferred, because it is more secure. See the [Enhanced Security Practices](https://uptane.github.io/deployment-considerations/security_considerations.html) section of this document for more techniques that can be used to limit rollback attacks when the Director repository is compromised.


## Adding, removing, or replacing ECUs

Sometimes it may be necessary for a dealership or mechanic to replace a particular ECU in a vehicle, or even add or remove one. This will mean that the vehicle version manifest will change -- even if the replacement ECU is an identical model, it will have a different ECU key. The Director may detect this as an attack, as an ECU suddenly using a new signing key could indicate a compromise.

We recommend dealing with this use case by establishing an out-of-band process that allows authorized mechanics to report a change to the OEM. By doing so, the change in ECU configuration will be recorded in the inventory database. Exactly what that process will look like depends on the size of the manufacturer, and the relative frequency of ECU replacements.

* A small luxury automaker might simply choose to allow authorized mechanics to send an email or make a phone call to an aftersales support person with the details of the new ECU, and have that person manually enter the details.
* A larger automaker might choose to deploy a dealer portal (i.e., a private, authenticated website) to allow authorized service centers to enter the details of the new ECU configuration themselves.

Another option for updating the ECU configuration is to have a process that temporarily "unlocks" an ECU configuration, allowing the vehicle's Primary to directly report its new configuration (as opposed to having the mechanic enter the details of the replaced ECU). There is a tradeoff here. While it streamlines the repair process, automating this step increases the risk that a real attack could go unnoticed.

Note, however, that these are only recommendations. Uptane does not prescribe a protocol for this use case because it is an orthogonal problem to software _update_ security. The advantage of this approach is that an OEM is free to solve this problem using existing solutions that it may already have in place.

### Aftermarket ECUs

A slightly more difficult use case to deal with concerns the use of aftermarket ECUs -- for example, 3rd-party replacement parts, or add-on ECUs that add functionality for commercial fleet management. Though from a technical perspective adding an aftermarket ECU can be managed in one of the ways recommended in the previous subsection, there is no doubt that these components bring with them a set of unique logistical and security concerns. For starters, because aftermarket suppliers may not have access to the original design, these ECUs are often products of reverse engineering. As such, suppliers may not be able to glean all relevant design information about the ECU, including the rationale behind certain choices. Furthermore, the use of these components raises a number of fundamental questions, such as:
- If an aftermarket ECU does not have its own primary, will it still be able to get updates through an existing OEM primary ECU, as long as the  OEMs Director repository permits it? 
- If an aftermarket ECU does have its own Primary, is each capable of controlling a mutually exclusive set of Secondaries?
- Could owners (or third parties) direct updates for their own vehicles from both an OEM and an aftermarket source? 

While at this point the easiest alternative might be to simply exclude aftermarket ECUs from receiving OTA updates, this might not be feasible. For starters, older vehicles depend heavily on aftermarket parts. Garages (including OEM dealers) regularly install aftermarket ECUs when an OEM stops producing them. Furthermore, the newly strengthened [Massachusetts Right-to-Repair law](https://en.wikipedia.org/wiki/2020_Massachusetts_Question_1) complicates both the distribution of ECU firmware updates and the attendant functional safety and cybersecurity issues. Among other provisions, the law mandates a platform to permit vehicle owners and independent mechanics to access telematics. Hence, OEMs may not have a say anymore on whether or not these units receive OTA updates.

Note that some aftermarket ECUs, such as those designed for fleet management or monitoring, may have their own independent internet connection, and thus do not need to be integrated into the OEM's update system at all. 

While at this point Uptane is not ready to include any specific guidance on aftermarket material use in its Standard, it is an issue the community is closely monitoring, particularly in the context of pending international standards such as [ISO/SAE 21434](https://www.iso.org/standard/70918.html). 

## Adding or removing a supplier

Due to changes in business relationships, an OEM may need to add or remove a tier-1 supplier from its repositories.

To add a tier-1 supplier, OEMs SHOULD use the following steps. All three steps should be performed using the guidelines in the [Normal Operating Procedures](https://uptane.github.io/deployment-considerations/normal_operation.html) section of this document. First, if the supplier signs its own images, then the OEM SHOULD add a delegation to the supplier on the Image repository. Second, the supplier SHOULD deliver metadata and/or images to the OEM. Finally, the OEM SHOULD add the metadata and images to its repositories, possibly test them, and then release them to the affected vehicles.

To safely remove a tier-1 supplier, the OEM SHOULD use the following steps. First, it SHOULD delete the corresponding delegation from the Targets role on the Image repository, as well as all metadata and images belonging to that supplier, so that their metadata and images are no longer trusted. Second, it SHOULD also delete information about the supplier from the Director repository, such as its images, as well as its dependencies and conflicts, so that the Director repository no longer chooses these images for installation. In order to continue to update vehicles with ECUs originally maintained by this supplier, the OEM SHOULD replace this supplier with another delegation, either one maintained by the OEM, or by another tier-1 supplier.

Note that to comply with the [Standard](https://uptane.github.io/papers/uptane-standard.2.0.0.html#check_snapshot), the Snapshot metadata must continue to list the removed delegation in order to prevent a rollback attack. However, if the OEM rotates the Timestamp and Snapshot keys (and pushes new Root metadata with the new keys), the delegation may be safely removed from the Snapshot metadata. As the ECU will need to clear out any existing Snapshot metadata due to the rotation, the check that each Targets metadata filename listed in the previous Snapshot metadata is also listed in the new Snapshot metadata will (trivially) not apply.

Tier-1 suppliers are free to manage delegations to members within its own organizations, or to tier-2 suppliers (who may delegate, in turn, to tier-3 suppliers, and so on), without involving the OEM.


## Key compromise

See [Key Management](key_management.html).

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