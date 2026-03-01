// Freestanding headers
#include <cstddef>

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

// Kernel entry point
extern "C" void kmain(void) {
	// Ensure Limine base revision is supported
	if(LIMINE_BASE_REVISION_SUPPORTED(limineBaseRev) == false) utils::hlt();

	// Framebuffer
	Framebuffer fb {};
	fb.drawLine();

	// Halt system
	utils::hlt();
}
