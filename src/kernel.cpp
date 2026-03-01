// Freestanding headers
#include <cstddef>

// Limine
#include <limine/limine.h>

// OS
#include <utils.hpp>

// Limine base revision
__attribute__((used, section(".limine_requests")))
static volatile uint64_t limineBaseRev[] = LIMINE_BASE_REVISION(5);

// Limine requests start and end marker
__attribute__((used, section(".limine_requests_start")))
static volatile uint64_t limineReqStartMarker[] = LIMINE_REQUESTS_START_MARKER;
__attribute__((used, section(".limine_requests_end")))
static volatile uint64_t limineReqEndMarker[] = LIMINE_REQUESTS_END_MARKER;

// Framebuffer
__attribute__((used, section(".limine_requests")))
static volatile struct limine_framebuffer_request fbRequest = {
    .id = LIMINE_FRAMEBUFFER_REQUEST_ID,
    .revision = 0,
	.response = nullptr,
};

// Kernel entry point
extern "C" void kmain(void) {
	// Ensure Limine base revision is supported
	if(LIMINE_BASE_REVISION_SUPPORTED(limineBaseRev) == false) utils::hlt();

	// Ensure we have a framebuffer and fetch the first available one
	if(fbRequest.response == nullptr || fbRequest.response->framebuffer_count < 1) utils::hlt();
	limine_framebuffer *fb = fbRequest.response->framebuffers[0];

	// Draw a line
	for (std::size_t i = 0; i < 100; i++) {
        volatile uint32_t *fbPtr = static_cast<volatile uint32_t *>(fb->address);
        fbPtr[i * (fb->pitch / 4) + i] = 0xffffff;
    }

	// Halt system
	utils::hlt();
}
