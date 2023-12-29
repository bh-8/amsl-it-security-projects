#include <yara/modules.h>
#include <inttypes.h>

#define MODULE_NAME numeric
//#define BE_VERBOSE

const uint8_t* block_data;
size_t block_size;

define_function(float32) {
    int64_t offset = integer_argument(1);

    #ifdef BE_VERBOSE
    printf("[float32] offset = %" PRId64 ", block size = %zd", offset, block_size);
    #endif

    //check if 4 bytes are available at given offset
    if (block_size > offset + 4) {
        //cast block data to float
        float* reinterpreted_numeric = (float*)(block_data + offset);

        #ifdef BE_VERBOSE
        printf(", float = %.6f\n", *reinterpreted_numeric);
        #endif

        //return
        return_float(*reinterpreted_numeric);
    } else {
        printf("\n[float32] WARNING: Given offset exceeds block size, can not convert!\n                   Returned -1 may result in broken rules!\n");

        return_float(-1);
    }
}
define_function(int64) {
    int64_t offset = integer_argument(1);

    #ifdef BE_VERBOSE
    printf("[int64] offset = %" PRId64 ", block size = %zd", offset, block_size);
    #endif

    //check if 8 bytes are available at given offset
    if (block_size > offset + 8) {
        //cast block data to int
        int64_t* reinterpreted_numeric = (int64_t*)(block_data + offset);

        #ifdef BE_VERBOSE
        printf(", int = %" PRId64 "\n", *reinterpreted_numeric);
        #endif
        /*printf("\n%02X %02X %02X %02X %02X %02X %02X %02X\n",
            *(block_data + offset),
            *(block_data + offset + 1),
            *(block_data + offset + 2),
            *(block_data + offset + 3),
            *(block_data + offset + 4),
            *(block_data + offset + 5),
            *(block_data + offset + 6),
            *(block_data + offset + 7));*/
 
        //return
        return_integer(*reinterpreted_numeric);
    } else {
        printf("\n[int64] WARNING: Given offset exceeds block size, can not convert!\n                   Returned -1 may result in broken rules!\n");

        return_integer(-1);
    }
}
define_function(int16seq) {
    int64_t offset = integer_argument(1);
    int64_t values = integer_argument(2);

    #ifdef BE_VERBOSE
    printf("[int16seq] offset = %" PRId64 ", block size = %zd", offset, block_size);
    #endif

    //check if 8 bytes are available at given offset
    if (block_size > offset + 2 * values) {
        //loop modbus registers
        for(int i = 0; i < values; i++) {
            uint16_t* reinterpreted_numeric = (uint16_t*)(block_data + offset + 2 * i);
            uint16_t converted = (*reinterpreted_numeric>>8) | (*reinterpreted_numeric<<8); 
            //numeric.int16seq(@modbus_read_holding_registers[1] + 7, 12) > 0
            printf("%02X %02X",
                *((uint8_t*)(reinterpreted_numeric)),
                *((uint8_t*)(reinterpreted_numeric) + 1));
            printf("  > int16 = %" PRIu16 "\n", converted);
        }
        printf("\n");

        return_integer(0);
    } else {
        printf("\n[int16seq] WARNING: Given offset exceeds block size, can not convert!\n                   Returned -1 may result in broken rules!\n");

        return_integer(-1);
    }
}

begin_declarations;
    declare_function("float32", "i", "f", float32);
    declare_function("int64", "i", "i", int64);
    declare_function("int16seq", "ii", "i", int16seq);
end_declarations;

int module_initialize(YR_MODULE* module) {
    return ERROR_SUCCESS;
}

int module_finalize(YR_MODULE* module) {
    return ERROR_SUCCESS;
}

int module_load(YR_SCAN_CONTEXT* context, YR_OBJECT* module_object, void* module_data, size_t module_data_size) {
    YR_MEMORY_BLOCK* block;

    block = first_memory_block(context);
    block_data = block->fetch_data(block);
    block_size = block->size;

    if (block_data != NULL) { }

    return ERROR_SUCCESS;
}

int module_unload(YR_OBJECT* module_object) {
    return ERROR_SUCCESS;
}

#undef MODULE_NAME
