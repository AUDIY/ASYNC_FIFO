# ASYNC_FIFO
**English version is [README.md](./README.md)**  
ベンダーに依存しない非同期FIFOのVerilogモジュール

## 概要
ASYNC_FIFOはFPGAベンダーに依存しない非同期FIFOモジュールです。  
作者が非同期FIFOの構造を理解するためにVerilog-2005で記述されています。  
テストベンチはSystemVerilog-2012で記述されています。

## 開発状況
![Version](https://img.shields.io/badge/Version-v0.12-green)
![license](https://img.shields.io/badge/license-CERN--OHL--W_v2-blue)

## 特徴
この非同期FIFOは以下4つの特徴をもちます。
### Almost Full/Empty
非同期FIFOが*Full/Empty*に到達する1サイクル前に*Almost Full/Empty*をアサートします。
### Programmable Full/Empty
メモリ内のデータが設定したしきい値より多くなった場合に*Programmable Full*、少なくなった場合に*Programmable Empty*をアサートします。
### Write/Read Protect
*Full*や*Empty*がアサートされている場合に誤ってデータを上書きしたり、すでに出力したデータを誤って再び出力することを防ぐことができます。
### 可変のグレイコードシンクロナイザ深さ
グレイコードを同期化する深さを一般的な2段よりも深くできます。クロック周波数が高いときにMTBFを改善できる場合があります。

## モジュール
本リポジトリは以下の2モジュールで構成されています。これらモジュールは[CERN-OHL-W v2](https://cern.ch/cern-ohl)でライセンスされています。
|モジュール名|概要|
|:----------|:---|
|[ASYNC_FIFO_ADDR_CTRL](https://github.com/AUDIY/ASYNC_FIFO/tree/main/src/ASYNC_FIFO_ADDR_CTRL)|RAMのアドレス生成およびそのグレイコード出力モジュール|
|[ASYNC_FIFO](https://github.com/AUDIY/ASYNC_FIFO/tree/main/src/ASYNC_FIFO)|非同期FIFO本体|

## 依存性
本モジュールは内部で[AUDIY_Verilog_IP](https://github.com/AUDIY/AUDIY_Verilog_IP)の以下のモジュールを使用します。**これらのコードは[CERN-OHL-P v2](https://cern.ch/cern-ohl)でライセンスされており、本リポジトリのライセンスの対象外です。**
|モジュール名|概要|
|:----------|:---|
|[BIN2GRAY](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/BIN2GRAY)|バイナリからグレイコードへの変換|
|[GRAY2BIN](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/GRAY2BIN)|グレイコードからバイナリへの変換|
|[SDPRAM_DUALCLK](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/Memory/SDPRAM_DUALCLK)|デュアルクロックのシンプルデュアルポートRAM|

## 備考
- メモリの深さは2のべき乗にのみ対応します。
- 現時点ではFWFT (First-Word Fall-Through) モードは正しく動作しません。将来的に対応予定です。
- 書き込み側と読み込み側のリセットは[ARESETN_SYNC](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/ARESETN_SYNC)の出力を接続するなどの方法でリセットを同時に行い、解除タイミングはそれぞれのクロックドメインで同期化してください。
- Almost Full/EmptyおよびProgrammable Full/Emptyはその検出の過程でグレイコードをバイナリに変換するため、Fmax確保に不利になる場合があります。不要な場合は未接続とすることで論理合成時に関連する回路が削除されFmaxに有利になる可能性があります。

## Licensed under CERN-OHL-W v2
Copyright AUDIY 2026.                                                       

This source describes Open Hardware and is licensed under the CERN-OHL-W v2.

You may redistribute and modify this source and make products using it under the terms of the CERN-OHL-W v2 (https://cern.ch/cern-ohl).

This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.  
Please see the CERN-OHL-W v2 for applicable conditions.

Source location: https://github.com/AUDIY/ASYNC_FIFO

As per CERN-OHL-W v2 section 4.1, should You produce hardware based on these sources, You must maintain the Source Location visible on the external case of the ASYNC_FIFO or other products you make using this source.