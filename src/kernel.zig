const c = @cImport({
	@cInclude("limine/limine.h");
});

// Limine base revision

// Limine requests markers
export var requestsStartMarker linksection(".limine_requests_start") = [4]u64{
	0xf6b8f4b39de7d1ae, 0xfab91a6940fcb9cf,
	0x785c6ed015d3e316, 0x181e920a7852b9d9,
};
export var requestsEndMarker linksection(".limine_requests_end") = [2]u64{
	0xadc0e0531bb10d03, 0x9572709f31764c62,
};

// Limine requests
export var fbRequest: c.limine_framebuffer_request linksection(".limine_requests") = .{
	.id = .{
		0xc7b1dd30df4c8b88, 0x0a82e883a194f07b,
		0x9d5827dcd881dd75,
		0xa3148604f6fab11b,
	},
	.revision = 0,
};

export fn _start() callconv(.c) noreturn {
	const fbResponse: *c.limine_framebuffer_response = @ptrCast(fbRequest.response orelse halt());
	const fb: *c.limine_framebuffer = @ptrCast(fbResponse.framebuffers[0]);
	drawPixel(fb, 5, 5, 0xffffff);
	halt();
}

fn drawPixel(framebuffer: *c.limine_framebuffer, xpos: usize, ypos: usize, color: u32) void {
	var fbPtr: [*]u32 = @ptrCast(@alignCast(framebuffer.address));
	fbPtr[ypos * framebuffer.pitch + xpos * (framebuffer.bpp / 8)] = color;
}

fn halt() noreturn {
	while(true) asm volatile("cli; hlt");
}
