#include <stdint.h>

volatile char* vga_buffer = (volatile char*)0xB8000;
static uint16_t vga_position = 0;

#define VGA_COLOR 0x07

#define VGA_DARK 0x0
#define VGA_BLUE 0x1
#define VGA_GREEN 0x2
#define VGA_CYAN 0x3
#define VGA_RED 0x4
#define VGA_PURPLE 0x5
#define VGA_YELLOW 0x6
#define VGA_GREY 0x8

// Функция вывода символа на экран
void put_char(char c) {
    if (c == '\n') {
        vga_position += 80 - (vga_position % 80);
    } else {
        vga_buffer[vga_position * 2] = c;
        vga_buffer[vga_position * 2 + 1] = VGA_COLOR;
        vga_position++;
    }
}

// Функция для вывода строки
void print(const char* str, int colornum) {
    while (*str) {
        if (*str == '\n') {
            vga_position += 80 - (vga_position % 80);
        } else {
            vga_buffer[vga_position * 2] = *str;
            vga_buffer[vga_position * 2 + 1] = colornum;
            vga_position++;
        }
        str++;
    }
}

// Чтение с порта (inline asm)
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// Простая функция для ожидания нажатия клавиши и получению символа
char get_char() {
    // Ждём пока клавиатура не отправит скан-код
    while (!(inb(0x64) & 1)) {
        // ждем флаг готовности в порту 0x64
    }
    uint8_t scancode = inb(0x60);
    
    // Пример перевода некоторых scancode в ASCII (очень базово)
    // Полноценная раскладка требует таблиц и обработки клавиш
    switch (scancode) {
        case 0x1E: return 'a';
        case 0x30: return 'b';
        case 0x2E: return 'c';
        case 0x20: return 'd';
        case 0x12: return 'e';
        case 0x21: return 'f';
        case 0x22: return 'g';
        case 0x23: return 'h';
        case 0x17: return 'i';
        case 0x24: return 'j';
        case 0x25: return 'k';
        case 0x26: return 'l';
        case 0x32: return 'm';
        case 0x31: return 'n';
        case 0x18: return 'o';
        case 0x19: return 'p';
        case 0x10: return 'q';
        case 0x13: return 'r';
        case 0x1F: return 's';
        case 0x14: return 't';
        case 0x16: return 'u';
        case 0x2F: return 'v';
        case 0x11: return 'w';
        case 0x2D: return 'x';
        case 0x15: return 'y';
        case 0x2C: return 'z';
        case 0x39: return ' '; // Пробел
        case 0x1C: return '\n'; // Enter
        default: return 0;
    }
}

static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

// Функция для установки курсора
void set_cursor_position(uint16_t position) {
    // Устанавливаем положение курсора
    uint16_t cursor_location = position;
    outb(0x3D4, 14); // Индекс верхнего байта курсора
    outb(0x3D5, cursor_location >> 8);
    outb(0x3D4, 15); // Индекс нижнего байта курсора
    outb(0x3D5, cursor_location & 0xFF);
}

// Функция для обновления позиции курсора
void update_cursor() {
    set_cursor_position(vga_position);
}

extern "C" void kernel_main(uint32_t memory_map_address) {
    print("Welcome to Irion OS\n", VGA_GREEN);
    print("Press 'help' to get help-list\n", VGA_COLOR);
    print("IRION > ", VGA_COLOR);

    update_cursor();
    char command[128];

    while (1) {
        char c = get_char();
        if (c) {
            put_char(c);
            update_cursor();
        }
        if (c == '\n') {
            print("IRION > ", VGA_COLOR);
            update_cursor();
        }
    }
}
