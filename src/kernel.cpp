// Freestanding headers
#include <stddef.h>

// Limine
#include <limine/limine.h>

// OS
#include <utils.hpp>
#include <drivers/fb.hpp>

// Limine base revision
__attribute__((used, section(".limine_requests")))
static volatile uint64_t limineBaseRev[] = LIMINE_BASE_REVISION(5);

// Limine requests start and end marker
__attribute__((used, section(".limine_requests_start")))
static volatile uint64_t limineReqStartMarker[] = LIMINE_REQUESTS_START_MARKER;
__attribute__((used, section(".limine_requests_end")))
static volatile uint64_t limineReqEndMarker[] = LIMINE_REQUESTS_END_MARKER;

// Limine Requests
__attribute__((used, section(".limine_requests")))
static volatile struct limine_firmware_type_request firmwareTypeRequest = {
	.id = LIMINE_FIRMWARE_TYPE_REQUEST_ID,
	.revision = 0,
	.response = nullptr,
};

// Font
extern ssfn_font_t _binary_fonts_unifont_sfn_start;

// Kernel entry point
extern "C" void kmain(void) {
	// Ensure Limine base revision is supported
	if(LIMINE_BASE_REVISION_SUPPORTED(limineBaseRev) == false) utils::hlt();
	struct limine_firmware_type_response *firmwareType = firmwareTypeRequest.response;

	// Framebuffer
	Framebuffer fb {{
		.font = &_binary_fonts_unifont_sfn_start,
		.width = 8,
		.height = 8,
	}, 0x000000, 0xffffff};

	ssfn_dst.bg = 0x00aa00;
	fb.clear();

	// Display firmware type
	switch(firmwareType->firmware_type) {
		case 0:
			printf("[FIRMWARE TYPE] x86 BIOS\n");
			break;
		case 1:
			printf("[FIRMWARE TYPE] 32-BITS UEFI\n");
			break;
		case 2:
			printf("[FIRMWARE TYPE] 64-BITS UEFI\n");
			break;
		case 3:
			printf("[FIRMWARE TYPE] SBI\n");
			break;
	}

	// Halt system
	utils::hlt();
}
