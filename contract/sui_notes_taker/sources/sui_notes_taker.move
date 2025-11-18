module sui_notes_taker::sui_notes_taker;

/// Imports
use sui::package;
use sui::display;
use sui::table;
use sui::table::Table;


// Error Codes
const ENotAuthorized: u64 = 1000;
const ENotRegistered: u64 = 1001;
const EAlreadyExists: u64 = 1002;
const EInvalidLength: u64 = 1003;
const EObjectDeleted: u64 = 1005;

/// Structs


public struct SUI_NOTES_TAKER has drop {}

public struct SuiNotesTakerAppManager has key, store {
  id: UID,
  users: Table<address, USER>
}

public struct USER has key, store{
  id: UID,
  user_address: address,
  folder_ids: vector<UID>,
  note_ids: vector<UID>,
  todo_ids: vector<UID>,
  created_at: u64
}

public struct UserCreatedEvent has copy, drop {
  user_id: ID,
  user_address: address,
  created_at: u64
}

public struct Folder has key, store {
  id: UID,
  owner: address,
  name: vector<u8>,
  note_ids: vector<UID>,
  is_deleted: bool,
  created_at: u64,
  updated_at:u64
}

public struct FolderCreatedEvent has copy, drop {
  folder_id: ID,
  owner_address: address,
  created_at: u64
}

public struct FolderDeletedEvent has copy, drop {
  folder_id: ID,
  owner_address: address,
  deleted_at: u64
}

public struct Note has key, store {
  id: UID,
  owner: address,
  folder_id: UID,
  title: vector<u8>,
  tags: vector<vector<u8>>,
  content_url: vector<u8>,
  created_at: u64,
  updated_at: u64,
  is_deleted: bool,
}

public struct NoteAddedEvent has copy, drop {
  note_id : ID,
  folder_id: ID,
  owner_address: address,
  created_at: u64
}

public struct NoteUpdatedEvent has copy, drop {
  note_id: ID,
  owner_address: address,
  updated_at: u64
}

public struct NoteDeletedEvent has copy, drop {
  note_id: ID,
  owner_address: address,
  deleted_at: u64
}

public struct Todo has key, store {
  id: UID,
  owner: address,
  title: vector<u8>,
  content_url: vector<u8>,
  due_date: u64,
  is_completed: bool,
  created_at: u64,
  updated_at: u64,
  is_deleted: bool
}

public struct TodoCreatedEvent has copy, drop {
  todo_id: ID,
  owner_address: address,
  created_at: u64
}

public struct TodoUpdatedEvent has copy, drop {
  todo_id: ID,
  owner_address: address,
  updated_at: u64
}

public struct TodoDeletedEvent has copy, drop {
  todo_id: ID,
  owner_address: address,
  deleted_at: u64
}


/// Initializing the module

fun init(otw: SUI_NOTES_TAKER, ctx: &mut TxContext) {
  
  let manager = SuiNotesTakerAppManager {
    id: object::new(ctx),
    users: table::new(ctx),
  };

  let publisher = package::claim(otw,ctx);

  // Folder Display Setup

  let folder_keys = vector[
    b"name".to_string(),
    b"description".to_string(),
    b"creator".to_string(),
  ];

  let folder_values = vector[
    b"{name}".to_string(),
    b"Folder created by {owner}".to_string(),
    b"{owner}".to_string()
  ];

  let mut folder_display = display::new_with_fields<Folder>(
    &publisher, folder_keys, folder_values, ctx
  );

  folder_display.update_version();
  transfer::public_transfer(folder_display, ctx.sender());

  // Note Display Setup


  let note_keys = vector[
    b"name".to_string(),
    b"description".to_string(),
    b"link".to_string(),
    b"creator".to_string(),
  ];

  let note_values = vector[
    b"{title}".to_string(),
    b"Tags: {tags}".to_string(),
    b"{content_url}".to_string(),
    b"{owner}".to_string()
  ];

  let mut note_display = display::new_with_fields<Note>(
    &publisher, note_keys, note_values, ctx
  );

  note_display.update_version();
  transfer::public_transfer(note_display, ctx.sender());

  // Todo Display Setup
  
  let todo_keys = vector[
    b"name".to_string(),
    b"description".to_string(),
    b"link".to_string(),
    b"creator".to_string()
  ];

  let todo_values = vector[
    b"{title}".to_string(),
    b"Completed: {is_completed} | Due: {due_date}".to_string(),
    b"{content_url}".to_string(),
    b"{owner}".to_string()
  ];

  let mut todo_display = display::new_with_fields<Todo>(
    &publisher, todo_keys, todo_values, ctx
  );

  todo_display.update_version();
  transfer::public_transfer(todo_display, ctx.sender());


  transfer::public_transfer(publisher, ctx.sender());
  transfer::share_object(manager);

}