---
layout: default
css_id: faq
---

# Frequently asked questions

### **What makes Uptane different from other SOTA security mechanisms?**





### **How does Uptane work with other systems and protocols?**




### **Must all signatures be valid for a threshold of signatures to be valid?**
The threshold requirement of Uptane, mentioned in [Section 5.4.4.3](https://uptane.github.io/uptane-standard/uptane-standard.html#check_root) and in descriptions of other roles, stipulates that a set number of keys are required to sign a metadata file. This is designed to prevent attacks by requiring would-be hackers to compromise multiple keys in order to install malware. However, what happens if this threshold is met, but one or more of the keys is not valid?

The Uptane Standard allows each implementer to decide whether these keys would be accepted. Take the following example:

Root metadata lists valid top-level Targets key identifiers are A, B, C, and D, with a threshold of 2. Should the following two metadata files be considered valid?

* Signed by A, B, and X, where X is not present at all in Root metadata

* Signed by A, B, and C, but B's signature doesn't actually match the signed content

The first case can happen when you include X in a newer version of Root metadata (for example the next iteration), so this has to be handled correctly or it will complicate the process of adding and rotating keys. The second case could happen when you are changing or adding signing algorithms. This case can occur if B is using a new signing scheme that the client currently does not understand, but will know how to parse it after the update.

Both the Uptane Standard and the Reference Implementation consider both of these cases valid, and the implementation also includes unit tests to verify this behavior.

We would welcome input from the community as to whether a case can be made for specifying one option over another.
