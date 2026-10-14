# NAND-Manager
Memory manager built on top of ONFI compliant controller made by @Ali9078.\
Model MT29F128G08AJAAAWP \

## Architecture Overview
#### ring_buffer
Simple ring buffer, stores incoming serial data.\
Configurable Parameters (and default values) \
|Parameter|Function|Default Value|
|:---|:---|:---|
|WIDTH|Defines the word size|8(bits)|
|PAGES|Number of pages in the buffer (page = 8640 words)|2|
|BAUD|Baud rate of incoming serial data|115200|

#### mem_block
Block to instantiate multiple ring_buffer modules and getting output according to mux input.
#### arbiter
Arbiters the requests from the ring_buffer modules to manage multiple input streams.
#### commanding_unit
Commands the nand_master to perform read and write operations to specific addresses.
#### addressing_unit
Stores and increments the read and write address pointers of various memory regions in the NAND Flash.

