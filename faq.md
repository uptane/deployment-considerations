---
layout: default
css_id: faq
---

# Frequently asked questions

### **What makes Uptane different from other SOTA security mechanisms?**

Security problems can occur due to accidental disclosures, malicious attacks, or disgruntled insiders.  It is not a matter of whether a successful attack will occur, but when.  Because of the very real threat of a compromise, a security system must be able to securely recover from an attack. This means that an update system must have a way to restore its operations in a timely fashion when a key is lost or compromised.

For example, suppose a nation-state actor steals a signing key and wants to use it to distribute software. Something similar happened in the 2011 [DigiNotar](https://en.wikipedia.org/wiki/DigiNotar) case, widely attributed to the Iranian government, in which 300,000 Iranian Gmail users were the main targets of a hack against the Dutch company. Following such an attack, a secure update system must provide a way to revoke the current trusted information, even if the adversary is able to be a man-in-the-middle for future communications.  Uptane is designed to provide strong security in cases like these by making sure failures are compartmentalized and limited in scope.

No other automotive-grade update system has been designed to work in such rigorous situations or has received more public scrutiny than Uptane.  We follow best practices in the security community by opening our design to wide-scale, public review.  This has proven essential time and time again to ensure a design will hold up against attackers, especially those as strong as nation-state actors.  Furthermore, Uptane's design is heavily influenced by the design of [TUF](https://theupdateframework.io/), a widely used software update system with a strong track record of usability and security across millions of devices.  As a free and open standard, with no cost to use or adopt, Uptane stands alone in the automotive update space.


### **How does Uptane work with other systems and protocols?**

Other mechanisms for performing updates, such as those offered by Red Bend, Movimento, and Tesla, are compatible with Uptane solely for handling data transport. Uptane can use any transport mechanism, and still provide strong security guarantees, even if the underlying network or transport mechanism is compromised. If a manufacturer wants to move to a secure update system, keeping their existing system as a transport mechanism for Uptane is an effective way to do so. See the [Customizing Uptane](https://uptane.github.io/deployment-considerations/customizations.html) section of this document.

### **What are the cost implications of integrating Uptane?**

A number of factors can influence the costs involved with implementing Uptane. If a project is starting from scratch, the cost would be minimal and any money spent would be just one component of the initial design. For existing OTA systems, the choice will be to either buy an off-the-shelf solution and do an integration, or to build a custom solution, with some greater or smaller degree of reliance on available open-source client and server components. There are pros and cons to both options, but ultimately, the issue of cost cannot be determined without also considering the value received for the expense. Value in this case is enhanced security, so when discussing costs, the trade-off between taking shortcuts and sacrificing security, or doing it right and spending more time/money, must be considered. A more detailed discussion on this issue can be found in the [Setting up Uptane repositories](http:/uptane.github.io/deployment-considerations/repositories.html) section.

### **Must all signatures be valid for a threshold of signatures to be valid?**

The threshold requirement of Uptane, mentioned in [Section 5.4.4.3](https://uptane.github.io/uptane-standard/uptane-standard.html#check_root) and in descriptions of other roles, stipulates that a set number of keys are required to sign a metadata file. This is designed to prevent attacks by requiring would-be hackers to compromise multiple keys in order to install malware. However, what happens if this threshold is met, but one or more of the keys is not valid?

The Uptane Standard allows each implementer to decide whether these keys would be accepted. Take the following example:

Root metadata lists valid top-level Targets key identifiers are A, B, C, and D, with a threshold of 2. Should the following two metadata files be considered valid?

* Signed by A, B, and X, where X is not present at all in Root metadata

* Signed by A, B, and C, but B's signature doesn't actually match the signed content

The first case can happen when you include X in a newer version of Root metadata (for example the next iteration), so this has to be handled correctly or it will complicate the process of adding and rotating keys. The second case could happen when you are changing or adding signing algorithms. This case can occur if B is using a new signing scheme that the client currently does not understand, but will know how to parse after the update.

Both the Uptane Standard and the Reference Implementation consider both of these cases valid, and the implementation also includes unit tests to verify this behavior.

We would welcome input from the community as to whether a case can be made for specifying one option over another.

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