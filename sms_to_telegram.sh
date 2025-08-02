#!/bin/sh

# Initialize variables
merged_message=""
sender_numbers=""

# Check if we have decoded parts (multipart message)
if [ "${DECODED_PARTS:-0}" -gt 0 ]; then
    # Process decoded multipart message
    for i in $(seq 1 $DECODED_PARTS); do
        decoded_text_var="DECODED_${i}_TEXT"
        eval decoded_text=\$${decoded_text_var}
        if [ -n "$decoded_text" ]; then
            merged_message="${merged_message}${decoded_text}"
        fi
    done
    # Get sender from first SMS message
    eval sender_numbers=\$SMS_1_NUMBER
else
    # Process individual SMS messages
    for i in $(seq 1 ${SMS_MESSAGES:-1}); do
        number_var="SMS_${i}_NUMBER"
        text_var="SMS_${i}_TEXT"
        eval current_number=\$${number_var}
        eval current_text=\$${text_var}
        
        if [ -n "$current_number" ] && [ -n "$current_text" ]; then
            # Add sender to list if not already present
            if [ -z "$sender_numbers" ]; then
                sender_numbers="$current_number"
            elif ! echo "$sender_numbers" | grep -q "$current_number"; then
                sender_numbers="${sender_numbers}, ${current_number}"
            fi
            
            # Add message text with sender prefix if multiple senders
            if [ -z "$merged_message" ]; then
                merged_message="$current_text"
            else
                merged_message="${merged_message}\n---\n$current_text"
            fi
        fi
    done
fi

# Create final message with sender info
if [ -n "$merged_message" ]; then
    final_message="From: ${sender_numbers}\n\n${merged_message}"
    
    # Send to Telegram using proper JSON escaping
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"${CHAT_ID}\",\"text\":\"${final_message}\"}"
    
    # Add pause to prevent rate limiting (Telegram allows 30 messages per second, so 1 second is safe)
    sleep 1
fi