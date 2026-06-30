export async function getAITutorResponse(payload: any) {
  const res = await fetch("/api/ai-tutor", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    throw new Error("AI Tutor failed");
  }

  return await res.json();
}