#define PERIPHERAL_TYPE_WIRELESS_CARD "WNET_ADAPTER"
#define PERIPHERAL_TYPE_CARD_READER "ID_SCANNER"
#define PERIPHERAL_TYPE_PRINTER "LAR_PRINTER"

// See proc/peripheral_input
#define PERIPHERAL_CMD_RECEIVE_PACKET "receive_packet"
#define PERIPHERAL_CMD_SCAN_CARD "scan_card"

// MedTrak menus
#define MEDTRAK_MENU_HOME 1
#define MEDTRAK_MENU_INDEX 2
#define MEDTRAK_MENU_RECORD 3

#define THINKDOS_ADMIN_ACC_NAME "admin"
#define THINKDOS_GUEST_ACC_NAME "guest"
#define THINKDOS_ADMIN_GROUP "administrators"
#define THINKDOS_USER_GROUP "users"

/// The magic owner that is all powerful
#define THINKDOS_OWNER_SYSTEM 0

/* The following are permissions for ThinkDOS and H.A.M.M.E.R
 * OWNER: Owner can take the given action. This will PROBABLY always exist on a file.
 * GROUP: If the accessor has the same group, it can perform the given action.
 * PUBLIC: Anyone can perform the action.
 */
#define PERM_READ_OWNER (1<<0)
#define PERM_READ_GROUP (1<<1)
#define PERM_READ_PUBLIC (1<<2)

#define PERM_WRITE_OWNER (1<<3)
#define PERM_WRITE_GROUP (1<<4)
#define PERM_WRITE_PUBLIC (1<<5)

#define PERM_EXECUTE_OWNER (1<<6)
#define PERM_EXECUTE_GROUP (1<<7)
#define PERM_EXECUTE_PUBLIC (1<<8)
