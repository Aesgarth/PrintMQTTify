# Shopping List Automation Scripts

This document showcases two scripts for automating the categorization and printing of a shopping list:

1. **Original Script**: A basic script that retrieves a shopping list, adds checkboxes, and sends it to a printer.
2. **AI-Powered Script**: An enhanced script that uses OpenAI's conversational capabilities to categorize the shopping list and add checkboxes only to the items within categories.

---

## Original Script

```yaml
alias: Print Shopping List
sequence:
  - data:
      status: needs_action
    target:
      entity_id: todo.mealie_shopping_list
    response_variable: shopping_list_response
    action: todo.get_items

  - data:
      message: "Shopping List Response: {{ shopping_list_response }}"
      level: info
    action: system_log.write

  - variables:
      shopping_list_message: >
        {%- set items = shopping_list_response['todo.mealie_shopping_list']['items'] -%}
        {%- for item in items -%}
        [ ] {{ item['summary'] }}
        {%- if not loop.last -%}
        {{ "\n" }}
        {%- endif -%}
        {%- endfor -%}

  - data:
      topic: printer/commands
      payload: |
        {%- set payload = {
          "printer_name": "SEWOO_LK-T100",
          "title": "Shopping List",
          "message": shopping_list_message
        } -%}
        {{ payload | tojson }}
    action: mqtt.publish
mode: single
```

---

## AI-Powered Script

```yaml
alias: Print Categorized Shopping List
sequence:
  - data:
      status: needs_action
    target:
      entity_id: todo.mealie_shopping_list
    response_variable: shopping_list_response
    action: todo.get_items

  - variables:
      shopping_list_items: >
        {%- set items = shopping_list_response['todo.mealie_shopping_list']['items'] -%}
        {%- for item in items -%}
        {{ item['summary'] }}
        {%- if not loop.last -%}
        {{ ", " }}
        {%- endif -%}
        {%- endfor -%}

  - service: conversation.process
    data:
      text: >
        Categorize: {{ shopping_list_items }}
      language: EN
      agent_id: conversation.chatgpt
      conversation_id: my_conversation_1
    response_variable: categorized_response

  - variables:
      categorized_message: >
        {%- set categorized_text = categorized_response.response.speech.plain.speech -%}
        {%- set lines = categorized_text.split('\n') -%}
        {%- for line in lines if line.strip() -%}
          {%- if line.startswith('-') and ':' not in line -%}
            [ ] {{ line }}
          {%- else -%}
            {{ line }}
          {%- endif -%}
        {%- if not loop.last -%}
        {{ "\n" }}
        {%- endif -%}
        {%- endfor -%}

  - data:
      message: "Categorized Shopping List with Checkboxes:\n{{ categorized_message }}"
      level: info
    action: system_log.write

  - data:
      topic: printer/commands
      payload: |
        {%- set payload = {
          "printer_name": "SEWOO_LK-T100",
          "title": "Categorized Shopping List",
          "message": categorized_message
        } -%}
        {{ payload | tojson }}
    action: mqtt.publish
mode: single
```

---

## Example Outputs

### Original Script Output
```plaintext
[ ] Milk
[ ] Bread
[ ] Apples
[ ] Sausages
```

### AI-Powered Script Output
```plaintext
Dairy:
[ ] Milk
Bakery:
[ ] Bread
Fruits:
[ ] Apples
Meat:
[ ] Sausages
```

---

## Features Comparison

| Feature                        | Original Script | AI-Powered Script |
|--------------------------------|-----------------|-------------------|
| Retrieve shopping list         | ✅              | ✅                |
| Add checkboxes to items        | ✅              | ✅                |
| Categorize items dynamically   | ❌              | ✅                |
| Add checkboxes only to items   | ❌              | ✅                |

---

This enhanced AI-powered script showcases the integration of OpenAI to provide smarter categorization, improving the usability and clarity of the printed shopping list.
