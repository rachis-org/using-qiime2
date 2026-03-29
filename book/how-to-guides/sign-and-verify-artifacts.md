# How to sign and verify Results

As of 2025.10 release, [Artifacts](xref:rachis-news-target#term-artifact) and [Visualizations](xref:rachis-news-target#term-visualization) (i.e. [Results](xref:rachis-news-target#term-result)) can now contain a cryptographic[^define-cryptography] [Signature](xref:rachis-news-target#term-signature), thus providing a method for verifying the identity of who created a [Result](xref:rachis-news-target#term-result).
Signing of [Results](xref:rachis-news-target#term-result) was introduced to better support secure distribution of machine learning classifiers packaged in `Results`.[^other-results-can-be-signed]
Because these [Results](xref:rachis-news-target#term-result) contain executable code, they represent more of a security risk than typical `Results` (which contain data files), so this enables users to verify the identity of the creator before using it on their computer where it will have access to sensitive data.
This is achieved using a new [Annotation](xref:rachis-news-target#term-annotation) sub-type: a [Signature](xref:rachis-news-target#term-signature).

This how-to guide will present:
 - pre-requisites for [signature](xref:rachis-news-target#term-signature) creation and verification;
 - how to add a [signature](xref:rachis-news-target#term-signature) to an existing [result](xref:rachis-news-target#term-result);
 - and how to verify a [result](xref:rachis-news-target#term-result) with an attached [signature](xref:rachis-news-target#term-signature).

## Pre-requisites for using Signatures

The tool we are leveraging for [signature](xref:rachis-news-target#term-signature) creation and verification is [GNU Privacy Guard](https://www.gnupg.org/documentation/index.html) (also known as GnuPG or GPG).
GPG is free, open-source software and in the context that we use it here, can be used for creating private/public keypairs, signing of [Results](xref:rachis-news-target#term-result), and verification of [Signatures](xref:rachis-news-target#term-signature) on signed [Results](xref:rachis-news-target#term-result).

This is all achieved by using a GPG keypair consisting of a private key and public key.
The private key is used to sign something, and should be securely managed by the signer (i.e. a person or organization) and never shared.
The public key is used to verify that a signature was created with its corresponding private key (and therefore by the individual or organization who securely manages that private key, assuming they are the only ones who ever had access to it).
The public key can be shared publicly.

(install-gpg)=
### Ensure that GPG is installed on your computer, or install it

```{note} We have intentionally chosen not to include GPG in our QIIME 2 environment files. Learn why here.
:class: dropdown

While installing and using GPG directly on your own machine is safe and recommended, distributing GPG through our Conda environments would require us (as software maintainers) to rely on additional third-party wrappers and distribution channels of GPG.
These added layers could expose the QIIME 2 [Distribution](xref:rachis-news-target#term-distribution) process to potential supply-chain or man-in-the-middle attacks whereby the software you (and we) think you're installing is not actually that software.
Because our signature functionality is intended to support secure use of Results, we ask users to install GPG directly from trusted system package sources to minimize risk.
```

Most modern computers come with GPG already installed; you can confirm whether or not you have GPG on your machine by running the following command in your terminal:

```shell
gpg --version
```

If GPG is installed, you should see something like the following:

```shell
gpg (GnuPG) 2.2.4
libgcrypt 1.8.1
Copyright (C) 2017 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Home: /home/ubuntu/.gnupg
Supported algorithms:
Pubkey: RSA, ELG, DSA, ECDH, ECDSA, EDDSA
Cipher: IDEA, 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH,
        CAMELLIA128, CAMELLIA192, CAMELLIA256
Hash: SHA1, RIPEMD160, SHA256, SHA384, SHA512, SHA224
Compression: Uncompressed, ZIP, ZLIB, BZIP2
```

If GPG is not installed on your machine, you'll see something like:

```shell
gpg: command not found
```

If GPG is not installed, you will need to install GPG before you can proceed.
You can find instructions on how to install GPG on [their website](https://www.gnupg.org/download/).

If you're only interested in verifying a signed result, at this point you can jump down to [](verify-signed-result).
If you'd like to sign a Result, and you already have a keypair you would like to use for this purpose, you can jump to [](sign-result).
If you'd like to sign a Result and don't already have a keypair, keep reading here.

(create-a-keypair)=
### Create a keypair, if you don't already have one

Before signing [Results](xref:rachis-news-target#term-result), you'll need to create a GPG keypair if you don't already have one.
Once GPG is installed on your machine, you can create a new keypair for use in [signature](xref:rachis-news-target#term-signature) creation.

You can create a new GPG keypair using the following command:

```shell
gpg --full-generate-key
```

You will then be prompted to make selections on the type of keypair to create.
Since the selections provided in GPG are subject to change over time, we have chosen not to go through them in this tutorial but we encourage you to review [GPG's keypair creation documentation](https://www.gnupg.org/gph/en/manual.html#AEN26).
Generally speaking, unless you have a reason not to, we recommend sticking with the defaults suggested by the keypair generation process.

After running this command successfully, you will have create a keypair and added it to your keychain.

(obtain-keypair-fingerprint)=
### Obtain keypair fingerprint

You will need your keypair's fingerprint to sign [Results](xref:rachis-news-target#term-result).
You can obtain the fingerprint of your keypair by using the following command:

```shell
gpg --fingerprint
```

The output of this command should look something like this:

```shell
pub   ed25519 2025-09-24 [SC] [expires: 2027-09-24]
      7B2B 042B D7F2 7AE4 DF86  18D0 80D7 286B 1D44 DB32
uid           [ultimate] Example User <example@mail.me>
sub   cv25519 2025-09-24 [E] [expires: 2027-09-24]
```

This command shows all of the keypairs on your GPG keyring.
If you have multiple keypairs present, you will see multiple entries that look something like the above example.

In each keypair entry, you will see a line that looks something like this:

```shell
7B2B 042B D7F2 7AE4 DF86  18D0 80D7 286B 1D44 DB32
```

This is the line that contains the keypair fingerprint.
Note the fingerprint so you can provide it as input when signing [Results](xref:rachis-news-target#term-result).

(sign-result)=
## Signing a Result

Using your [keypair fingerprint](obtain-keypair-fingerprint), you can create a new [Signature](xref:rachis-news-target#term-signature) annotation to sign [Results](xref:rachis-news-target#term-result).
Note that only [Results](xref:rachis-news-target#term-result) created with QIIME 2 version 2025.4 (or newer) can be signed.

Below is the workflow for signing an example [Result](xref:rachis-news-target#term-result) (`my-result.qza`) with an example keypair fingerprint.

`````{tab-set}

````{tab-item} Command line interface
```shell
qiime tools annotation-create \
  --input-path my-result.qza \
  --annotation-type Signature \
  --name 'mysignature' \
  --fingerprint '7B2B 042B D7F2 7AE4 DF86  18D0 80D7 286B 1D44 DB32' \
  --output-path my-signed-result.qza
```
````

````{tab-item} Python 3 API
```python
import qiime2
from qiime2.core.annotate import Signature

result = qiime2.sdk.Result.load('my-result.qza')
signature = \
    Signature(name='mysignature',
              fingerprint='7B2B 042B D7F2 7AE4 DF86  18D0 80D7 286B 1D44 DB32')

result.add_annotation(signature)
result.save('my-signed-result.qza')
```
````
`````

At this point, you have signed the result (`my-signed-result.qza`).
You should first verify it yourself, to make sure everything worked as expected, and then it can be shared with your public key[^exchanging-gpg-keys] to allow others to verify it.
Instructions for verifying signed results follow.

(verify-signed-result)=
## Verifying a Signed Result

```{note}
[You may need to install `gpg`](install-gpg) before running the commands in this section.
```

A signed [Result](xref:rachis-news-target#term-result) (either created by you or provided by someone else) can be verified by anyone who has the signer's public key in their GPG keyring[^exchanging-gpg-keys].

Below is the workflow for verifying a signed [result](xref:rachis-news-target#term-result) using an example [result](xref:rachis-news-target#term-result).

First, find the name of the signature that you'd like to verify by running the following command to list all [annotations](xref:rachis-news-target#term-annotation) attached to the [result](xref:rachis-news-target#term-result). These will be the `Annotations` of type `Signature`, and you should note the corresponding `name` value.

`````{tab-set}

````{tab-item} Command line interface
```shell
qiime tools annotation-list \
  --input-path signed-result.qza

ID:        ccbedc23-03f0-4092-ac24-4eeed467ece1
name:      signature-name
type:      Signature
```
````

````{tab-item} Python 3 API
```python
import qiime2

result = qiime2.sdk.Result.load('signed-result.qza')

for annotation in result.iter_annotations():
    print(f"Name: {annotation.name}\nType: {annotation.annotation_type}")

Name: signature-name
Type: Signature
```
````
`````

In this example, the name is `signature-name`.

Next, verify the signature as follows, providing the name:

`````{tab-set}

````{tab-item} Command line interface
```shell
qiime tools signature-verify \
  --input-path my-signed-result.qza \
  --name 'signature-name'
```
````

````{tab-item} Python 3 API
```python
import qiime2

result = qiime2.sdk.Result.load('signed-result.qza')
result.verify('signature-name')
```
````
`````

If the [Signature](xref:rachis-news-target#term-signature) is verified successfully, you will see the following:

`````{tab-set}

````{tab-item} Command line interface
```shell
Signature signature-name on Result signed-result.qza verified successfully.
```
````

````{tab-item} Python 3 API
```python
'Signature `signature-name` verified successfully.'
```
````
`````

If [Signature](xref:rachis-news-target#term-signature) verification fails, you will receive an error message with details on the failure.
If verification fails, you should not use the [result](xref:rachis-news-target#term-result) and contact the person or organization who you were expecting to obtain it from to let them know that signature verification failed.


[^other-results-can-be-signed]: While this functionality was developed for the purpose of securing machine learning classifiers (to assert the identity of the person or organization who trained them), it can be used for any type of [result](xref:rachis-news-target#term-result) when you'd like to prove that it is coming from a trusted source.
[^exchanging-gpg-keys]: [This section](https://www.gnupg.org/gph/en/manual.html#AEN57) of the GPG documentation walks through exchanging public keys, which includes both how to export your public key to share with someone, and how to import someone else's public key to your keyring.
[^define-cryptography]: Cryptography: the discipline concerned with communication security (eg, confidentiality of messages, integrity of messages, sender authentication, non-repudiation of messages, and many other related issues), regardless of the used medium such as pencil and paper or computers.
 This definition was [obtained from wiktionary](https://en.wiktionary.org/wiki/cryptography), accessed on 17 Nov 2025.
