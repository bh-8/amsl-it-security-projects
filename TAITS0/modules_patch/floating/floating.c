#include <yara/modules.h>
#include <inttypes.h>

#define MODULE_NAME floating
#define BE_VERBOSE

const uint8_t* block_data;
size_t block_size;

define_function(float32) {
    int64_t offset = integer_argument(1);

    #ifdef BE_VERBOSE
    printf("[float32] offset = %" PRId64 ", block size = %zd", offset, block_size);
    #endif

    if (block_size > offset + 4) {
        float* reinterpreted_numeric = (float*)(block_data + offset);

        #ifdef BE_VERBOSE
        printf(", float = %.6f\n", *reinterpreted_numeric);
        #endif

        return_float(*reinterpreted_numeric);
    } else {
        #ifdef BE_VERBOSE
        printf("\n[float32] WARNING: Given offset exceeds block size, can not convert!\n");
        #endif

        return_float(-1);
    }
}

begin_declarations;
    declare_function("float32", "i", "f", float32);
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
