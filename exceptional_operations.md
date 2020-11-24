---
layout: default
css_id: exceptional_operations
---

# Exceptional operations

On this page, we discuss operations that are generally performed only in exceptional cases. As performing these operations may have security implications for software updates, they should be carried out with great care.

## Rolling back software

Sometimes an OEM may determine that the latest updates are less reliable than previous ones.  In that case, it may be necessary to roll back to a previous update.

By default, Uptane does not allow updates to be rolled back and enforces this action with two mechanisms. First, Uptane rejects any new metadata file with a version number lower than the one contained in the previous metadata file. Second, Uptane will reject any new image associated with a release counter that is lower than the release counter of the previous image in the previous Targets metadata file. The first mechanism prevents an attacker from replaying an old metadata file. The second mechanism prevents an attacker who compromises the Director repository from being able to choose old versions of images, despite being able to sign new metadata. See Figure 1 for an example.

<img align="center" src="assets/images/except_1_.rollback_prev.png" width="500" style="margin: 0px 20px"/>

**Figure 1.** *Uptane prevents rollback attacks by rejecting older: (1) metadata files, and / or (2) images.*

There are at least two ways to allow rollbacks, each with different advantages and disadvantages.

In the first option, an OEM MAY choose to never increment the release counters of images (see Figure 2). Uptane will accept any new image associated with a release counter, as long as it is equal to the release counter of the previous image in the previous Targets metadata file. If release counters are never incremented, then all images would have the same release counters. In this situation, an ECU would accept the installation of any compatible image referred to in the new Targets metadata. (See the [Security considerations](https://uptane.github.io/deployment-considerations/security_considerations.html) section.)

<img align="center" src="assets/images/except_2_diffimage_samecounter.png" width="500" style="margin: 0px 20px"/>

**Figure 2.** *Uptane allows the installation of images that have the same release counter as what is currently installed.*

The advantage to this method is that it is simple. It allows the OEM to easily install interchangeable versions of the same image. In the example shown in Figure 2, “foo.img” may simply be a version of “bar.img” containing diagnostic functions. Therefore, the OEM may install either “bar.img” or “foo.img’ on the same ECU. The disadvantage of this method is that it allows attackers who compromise the Director repository to install obsolete images they can use to execute rollback attacks. Therefore, this method SHOULD NOT be used.

In the second option, an OEM increments the release counter of an image whenever it is critical that an ECU not install images with lower release counters. In the example in Figure 3, if an ECU installs “foo.img,” then it cannot install “bar.img.” This is done to prevent the installation of compatible images with lower release counters that have known security vulnerabilities, rather than newer images in which these vulnerabilities have been fixed.

<img align="center" src="assets/images/except_3_diffimage_samecounter2.png" width="500" style="margin: 0px 20px"/>

**Figure 3.** *Uptane forbids the installation of images with lower release counters than what is currently installed.*

The advantage to this method is that it prevents rollback attacks in a situation
where attackers compromise only the Director repository.  However, there are two disadvantages. First, the release counters for images have to be maintained, even if role B now signs for images previously signed by role A. This is because release counters are always compared to previous Targets metadata files. Second, it is more cumbersome to roll back updates, or deliberately cause ECUs to install older images, because the release counters of these older images are incremented in the new Targets metadata for the Image repository with offline keys. However, this method SHOULD be preferred, because it is more secure. See the [Security considerations](https://uptane.github.io/deployment-considerations/security_considerations.html) section for more techniques that can be used to limit rollback attacks when the Director repository is compromised.


## Adding, removing, or replacing ECUs

Sometimes, it may be necessary for a dealership or mechanic to replace a particular ECU in a vehicle, or even add or remove one. This will mean that the vehicle version manifest will change--even if the replacement ECU is an identical model, it will have a different ECU key. The Director may detect this as a security attack, as an ECU suddenly using a new signing key could be indicative of a compromise.

We recommend dealing with this use case by establishing an out-of-band process that allows authorized mechanics to report a change to the OEM. By doing so, the change in ECU configuration is recorded in the inventory database. Exactly what that process looks like will depend on the size of the automaker and the relative frequency of ECU replacements.

* A small luxury automaker might simply choose to allow authorized mechanics to send an email or make a phone call to an aftersales support person with the details of the new ECU, and have that person manually enter the details.
* A larger automaker might choose to deploy a dealer portal (i.e., a private, authenticated website) to allow authorized service centers to enter the details of the new ECU configuration themselves.

Another option for updating the ECU configuration is to have a process that temporarily "unlocks" an ECU configuration, allowing the vehicle's Primary to directly report its new configuration (as opposed to having the mechanic enter the details of the replaced ECU). There is a tradeoff here. While it streamlines the repair process, automating this step increases the risk that a real attack could go unnoticed.

Note, however, that these are only recommendations. Uptane does not prescribe a protocol for this use case, because it is an orthogonal problem to software _update_ security. The advantage of this approach is that an OEM is free to solve this problem using existing solutions that it may already have in place.

### Aftermarket ECUs

A slightly more difficult use case to deal with are aftermarket ECUs--for example, 3rd-party replacement parts, or add-on ECUs that add functionality for commercial fleet management. One approach is to work with the ECU manufacturer and treat them like any other tier-1. (The addition of the aftermarket ECU would be managed in one of the ways recommended in the previous section.) However, this may not be economically feasible in many cases. The easiest alternative is to simply exclude the aftermarket ECU from receiving OTA updates.

Some aftermarket ECUs, such as those designed for fleet management or monitoring, may have their own independent internet connection, and thus do not need to be integrated into the OEM's update system at all.

## Adding or removing a supplier

Due to changes in business relationships, an OEM may need to add or remove a tier-1 supplier from its repositories.

To add a tier-1 supplier, OEMs SHOULD use the following steps. All three steps should be performed using the guidelines in the [Normal Operating Procedures](https://uptane.github.io/deployment-considerations/normal_operation.html) section. First, if the supplier signs its own images, then the OEM SHOULD add a delegation to the supplier on the image repository. Second, the supplier SHOULD deliver metadata and/or images to the OEM. Finally, the OEM SHOULD add the metadata and images to its repositories, possibly test them, and then release them to the affected vehicle.

To safely remove a tier-1 supplier, the OEM SHOULD use the following steps. First, it SHOULD delete the corresponding delegation from the Targets role on the Image repository, as well as all metadata and images belonging to that supplier, so that their metadata and images are no longer trusted. Second, it SHOULD also delete information about the supplier from the Director repository, such as its images, as well as its dependencies and conflicts, so that the Director repository no longer chooses these images for installation. In order to continue to update vehicles with ECUs originally maintained by this supplier, the OEM SHOULD replace this supplier with another delegation, either maintained by itself or by another tier-1 supplier.

Note that to comply with the [Standard](https://uptane.github.io/papers/ieee-isto-6100.1.0.0.uptane-standard.html#check_snapshot), the Snapshot metadata must continue to list the removed delegation in order to prevent a rollback attack. However, if the OEM rotates the Timestamp and Snapshot keys (and pushes new Root metadata with the new keys), the delegation may be safely removed from the Snapshot metadata. As the ECU will need to clear out any existing Snapshot metadata due to the rotation, the check that each Targets metadata filename listed in the previous Snapshot metadata is also listed in the new Snapshot metadata will (trivially) not apply.

Tier-1 suppliers are free to manage delegations to members within its own organizations, or tier-2 suppliers (who may delegate, in turn, to tier-3 suppliers), without involving the OEM.


## Key compromise

See [Key Management](key_management.html).
