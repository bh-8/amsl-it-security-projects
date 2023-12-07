#include <yara/modules.h>
#include <inttypes.h>

#define MODULE_NAME floating

const uint8_t* block_data;
size_t block_size;

define_function(float32) {
    int64_t offset = integer_argument(1);
    printf("[float32] offset = %" PRId64 ", block size = %zd\n", offset, block_size);
    //TODO: kochvorgang yara: konkret offset raussuchen, um korrektes offset hier als input zu bekommen
    if (block_size > offset + 4) {
        printf("[0] = %" PRIu8 "\n", block_data[offset]);
        printf("[1] = %" PRIu8 "\n", block_data[offset + 1]);
        printf("[2] = %" PRIu8 "\n", block_data[offset + 2]);
        printf("[3] = %" PRIu8 "\n", block_data[offset + 3]);
        //TODO: Speicherbereich im einfachsten fall als float ptr interpretieren
        //      ansonsten selbst umwandeln zur not mit memcpy und xor
    } else {
        printf("[float32] WARNING: Given offset exceeds block size, can not convert!");
    }

    return_integer(offset);
}

begin_declarations;
    declare_function("float32", "i", "i", float32);
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
