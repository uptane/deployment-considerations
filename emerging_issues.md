---
layout: default
css_id: emerging_issues
---

# Emerging Issues

As the potential cyber threat against vehicles continues to rise, with [one industry survey](https://upstream.auto/upstream-security-global-automotive-cybersecurity-report-2020/) showing attacks increasing by 99% from 2018 to 2019, and by 700% since 2016, Uptane acknowledges a need to stay well-informed on tomorrow's security issues as well as today's. Towards this end, the Uptane community has identified several emerging issues that will significantly influence the framework and its deployment in the months and years ahead. Below we offer a brief summary of those relevant issues, along with a link to the GitHub issue threads for each. We welcome input from all in the Uptane Community in helping us respond to these new challenges.

**Allowing access to ECUs for emergency updates from federal/state/local governments:** 
As SOTA delivery of updates becomes more sophisticated, government agencies and regulatory bodies, such as the U.S. Department of Transportation or its state and equivalents, the Department of Homeland Security, or the Federal Emergency Management Agency (or similar agencies in other nations), may require automakers to grant them full control over a vehicle in emergency situations. These infrequent but important OTA broadcasts could be due to emergency or disaster routing, scheduled road work, or traffic conditions due to closed exits, failed stoplights or other conditions.  Accommodating this access will require some re-thinking of how Uptane is configured, particularly in how to prioritize delegations, and perhaps to accommodate a dual director set-up. (See Issue #162 at https://github.com/uptane/uptane-standard/issues/162.)

**Security issues related to the use of aftermarket materials:**
Aftermarket companies refurbish and reuse equipment following end-of-life support from OEMs. This means introducing ECUs to a vehicle that the OEM cannot control in any manner. In addition, because aftermarket suppliers may not have access to the original design, they often must reverse engineer the parts to figure out how they work. Such an approach means suppliers are not able to glean all relevant design information about the ECU, particularly the institutional knowledge behind the design decisions made by the original development team. In resolving how Uptane can best adapt to this challenge, we must consider questions like the following: If an aftermarket ECU does not have its own Primary, will it still be able to get updates through an existing OEM Primary ECU, as long as the OEM's Director repository permits it? If an aftermarket ECU does have its own Primary, is each capable of controlling a mutually exclusive set of Secondaries?
Could an owner (or a third-party) direct updates for their own vehicle from both an OEM and an aftermarket source? (See Issue #200 at https://github.com/uptane/uptane-standard/issues/200.)

**Are there more secure alternatives for hardware and software identifiers than supplier-name-prefixed serial numbers?**
There has been considerable efforts over the past few years to develop consistent and appropriate identifiers for both hardware and software components. Traditionally, a supplier-name-prefixed serial number, such as a VIN number, has been used to identify ECUs, but this method does not acknowledge the differing nature of ECUs. Given that not all ECUs share the same resources, what does an identifier actually need to share? In the software realm, the use of IETF Standard for Concise Software Identification Tags that are more secure than current supplier/OEM proprietary software version info is becoming commonplace. Concise SWID (CoSWID) tags, according to IETF's Datatracker (https://datatracker.ietf.org/doc/draft-ietf-sacm-coswid/), "support a similar set of semantics and features as SWID tags, as well as new semantics that allow CoSWIDs to describe additional types of information, all in a more memory efficient format." (See https://github.com/uptane/uptane-standard/issues/230)

**Responding to emerging legislation and standards**
In dealing with these technical issues, Uptane also is aware of an increased focus on cybersecurity in regulations and standards governing the vehicle market. The Uptane Standards group is monitoring the current and pending development of these regulatory documents and, in resolving these and other future issues, will ensure Uptane is compliant. The [Regulations and Standards Relevant to Uptane](https://github.com/uptane/deployment-considerations/blob/master/regulations_and_standards.md) section of this document lists the relevant standards we are currently tracking.

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